import { useState, useMemo, useEffect, useCallback } from "react";
import { Plus, Download, RefreshCw, AlertCircle } from "lucide-react";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { UserFilters } from "../components/users/UserFilters";
import { UserTable } from "../components/users/UserTable";
import { UserAuditLog } from "../components/users/UserAuditLog";
import { UserStatsCards } from "../components/users/UserStatsCards";
import { EditUserModal } from "../components/users/EditUserModal";
import { AddUserModal } from "../components/users/AddUserModal";
import { BulkActionsBar } from "../components/users/BulkActionsBar";
import { UserPagination } from "../components/users/UserPagination";
import { Button } from "../components/ui/button";
import { toast } from "../hooks/use-toast";
import { useAuth } from "../context/AuthContext";
import { getUsers, approveUser, suspendUser, rejectUser, reinstateUser } from "../lib/api";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "../components/ui/alert-dialog";

// Normalize a single user from the backend shape to the UI shape
function normalizeUser(u) {
  const rawStatus = (u.status ?? u.accountStatus ?? "pending").toLowerCase();
  // Backend uses "approved" — map to "active" for the UI
  const status = rawStatus === "approved" ? "active" : rawStatus;

  return {
    id: String(u._id ?? u.id ?? u.userId ?? u.user_id),
    name: u.fullName ?? u.name ?? u.full_name ?? u.username ?? "Unknown",
    email: u.email ?? "",
    role: (u.role ?? u.userRole ?? "volunteer").toLowerCase(),
    status,
    region: u.province ?? u.region ?? u.area ?? "",
    organization: u.organization ?? "",
    designation: u.designation ?? "",
    createdAt: u.createdAt ?? u.created_at ?? u.joinedAt ?? new Date().toISOString(),
    lastLogin: u.lastLogin ?? u.last_login ?? null,
  };
}

const UserManagement = () => {
  const { token } = useAuth();

  const [users, setUsers] = useState([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [fetchError, setFetchError] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [addModalOpen, setAddModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [selectedUsers, setSelectedUsers] = useState(new Set());
  const [bulkDeleteOpen, setBulkDeleteOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(5);

  const fetchUsers = useCallback(async () => {
    setLoadingUsers(true);
    setFetchError("");
    try {
      const data = await getUsers(token);
      const list = Array.isArray(data) ? data : (data.users ?? data.data ?? data.content ?? []);
      setUsers(list.map(normalizeUser));
    } catch (err) {
      setFetchError(err.message || "Failed to load users.");
    } finally {
      setLoadingUsers(false);
    }
  }, [token]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  // Filter users (client-side for now; search/role/status could also be sent as query params)
  const filteredUsers = useMemo(() => {
    return users.filter((user) => {
      const matchesSearch =
        user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        user.email.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesRole = roleFilter === "all" || user.role === roleFilter;
      const matchesStatus = statusFilter === "all" || user.status === statusFilter;
      return matchesSearch && matchesRole && matchesStatus;
    });
  }, [users, searchQuery, roleFilter, statusFilter]);

  // Pagination
  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize));
  const paginatedUsers = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return filteredUsers.slice(start, start + pageSize);
  }, [filteredUsers, currentPage, pageSize]);

  const handleFilterChange = (setter) => (value) => {
    setter(value);
    setCurrentPage(1);
  };

  const handlePageSizeChange = (size) => {
    setPageSize(size);
    setCurrentPage(1);
  };

  // Stats derived from loaded users
  const stats = useMemo(() => ({
    total: users.length,
    active: users.filter((u) => u.status === "active").length,
    pending: users.filter((u) => u.status === "pending").length,
    suspended: users.filter((u) => u.status === "suspended").length,
  }), [users]);

  // ── API-backed actions ────────────────────────────────────────────────────

  const handleApprove = async (userId) => {
    try {
      await approveUser(token, userId);
      setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, status: "active" } : u));
      toast({ title: "User approved", description: "The user account has been approved." });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  const handleSuspend = async (userId) => {
    try {
      await suspendUser(token, userId);
      setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, status: "suspended" } : u));
      toast({ title: "User suspended", description: "The user account has been suspended.", variant: "destructive" });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  const handleReinstate = async (userId) => {
    try {
      await reinstateUser(token, userId);
      setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, status: "active" } : u));
      toast({ title: "User reinstated", description: "The user account has been reinstated." });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  const handleReject = async (userId) => {
    try {
      await rejectUser(token, userId, "Rejected by admin");
      setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, status: "rejected" } : u));
      toast({ title: "User rejected", description: "The user account has been rejected.", variant: "destructive" });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  // UserTable calls onApprove for both "Approve" and "Reactivate" clicks.
  // Route based on current status.
  const handleApproveOrReinstate = async (userId) => {
    const user = users.find((u) => u.id === userId);
    if (!user) return;
    if (user.status === "suspended" || user.status === "rejected") {
      await handleReinstate(userId);
    } else {
      await handleApprove(userId);
    }
  };

  const handleEdit = (user) => {
    setSelectedUser(user);
    setEditModalOpen(true);
  };

  const handleSaveEdit = (userId, data) => {
    setUsers(users.map((u) =>
      u.id === userId
        ? { ...u, name: data.name, email: data.email, role: data.role, region: data.region }
        : u
    ));
    toast({
      title: "User updated",
      description: `${data.name}'s details have been updated successfully.`,
    });
  };

  const handleAddUser = (data) => {
    const newUser = {
      id: crypto.randomUUID(),
      name: data.name,
      email: data.email,
      role: data.role,
      status: "pending",
      region: data.region,
      createdAt: new Date().toISOString(),
    };
    setUsers([newUser, ...users]);
    toast({
      title: "User created",
      description: `${data.name} has been added and will receive an invitation email.`,
    });
  };

  // Local-only delete (no delete endpoint in spec)
  const handleDelete = (userId) => {
    setUsers(users.filter((u) => u.id !== userId));
    selectedUsers.delete(userId);
    setSelectedUsers(new Set(selectedUsers));
  };

  const handleBulkApprove = async () => {
    const ids = [...selectedUsers];
    await Promise.allSettled(ids.map((id) => handleApproveOrReinstate(id)));
    toast({ title: "Bulk approve complete", description: `${ids.length} user(s) processed.` });
    setSelectedUsers(new Set());
  };

  const handleBulkSuspend = async () => {
    const ids = [...selectedUsers];
    await Promise.allSettled(ids.map((id) => handleSuspend(id)));
    toast({ title: "Bulk suspend complete", description: `${ids.length} user(s) suspended.`, variant: "destructive" });
    setSelectedUsers(new Set());
  };

  const handleBulkDelete = () => {
    const count = selectedUsers.size;
    setUsers(users.filter((u) => !selectedUsers.has(u.id)));
    toast({ title: "Users deleted", description: `${count} user(s) have been removed from the system.` });
    setSelectedUsers(new Set());
    setBulkDeleteOpen(false);
  };

  const clearFilters = () => {
    setSearchQuery("");
    setRoleFilter("all");
    setStatusFilter("all");
    setCurrentPage(1);
  };

  return (
    <div className="flex min-h-screen w-full bg-background">
      <AppSidebar />

      <div className="flex-1 flex flex-col">
        <Header />

        <main className="flex-1 p-6 overflow-auto">
          {/* Page Header */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
            <div>
              <h1 className="text-2xl font-bold text-foreground">User Management</h1>
              <p className="text-muted-foreground">
                Manage system users, roles, and permissions
              </p>
            </div>
            <div className="flex gap-3">
              <Button
                variant="outline"
                className="gap-2 border-border/50 bg-muted/30"
                onClick={fetchUsers}
                disabled={loadingUsers}
              >
                <RefreshCw className={`w-4 h-4 ${loadingUsers ? "animate-spin" : ""}`} />
                Refresh
              </Button>
              <Button variant="outline" className="gap-2 border-border/50 bg-muted/30">
                <Download className="w-4 h-4" />
                Export
              </Button>
              <Button
                className="gap-2 bg-primary text-primary-foreground hover:bg-primary/90"
                onClick={() => setAddModalOpen(true)}
              >
                <Plus className="w-4 h-4" />
                Add User
              </Button>
            </div>
          </div>

          {/* Error Banner */}
          {fetchError && (
            <div className="flex items-center gap-3 p-4 mb-6 rounded-xl bg-destructive/10 border border-destructive/20 text-destructive">
              <AlertCircle className="w-5 h-5 shrink-0" />
              <p className="text-sm flex-1">{fetchError}</p>
              <Button size="sm" variant="outline" onClick={fetchUsers} className="border-destructive/30 text-destructive hover:bg-destructive/10">
                Retry
              </Button>
            </div>
          )}

          {/* Loading skeleton */}
          {loadingUsers && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="glass-card rounded-xl p-6 animate-pulse">
                  <div className="flex items-center justify-between">
                    <div className="space-y-2">
                      <div className="h-3 w-24 bg-muted rounded" />
                      <div className="h-8 w-16 bg-muted rounded" />
                    </div>
                    <div className="w-12 h-12 rounded-xl bg-muted" />
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Stats Cards */}
          {!loadingUsers && (
            <UserStatsCards
              totalUsers={stats.total}
              activeUsers={stats.active}
              pendingUsers={stats.pending}
              suspendedUsers={stats.suspended}
            />
          )}

          {/* Main Content */}
          <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
            {/* User Table Section */}
            <div className="xl:col-span-2">
              <UserFilters
                searchQuery={searchQuery}
                onSearchChange={handleFilterChange(setSearchQuery)}
                roleFilter={roleFilter}
                onRoleChange={handleFilterChange(setRoleFilter)}
                statusFilter={statusFilter}
                onStatusChange={handleFilterChange(setStatusFilter)}
                onClearFilters={clearFilters}
              />
              <BulkActionsBar
                selectedCount={selectedUsers.size}
                onApprove={handleBulkApprove}
                onSuspend={handleBulkSuspend}
                onDelete={() => setBulkDeleteOpen(true)}
                onClear={() => setSelectedUsers(new Set())}
              />
              <UserTable
                users={paginatedUsers}
                selectedUsers={selectedUsers}
                onSelectionChange={setSelectedUsers}
                onApprove={handleApproveOrReinstate}
                onSuspend={handleSuspend}
                onEdit={handleEdit}
                onDelete={handleDelete}
              />
              <UserPagination
                currentPage={currentPage}
                totalPages={totalPages}
                pageSize={pageSize}
                totalItems={filteredUsers.length}
                onPageChange={setCurrentPage}
                onPageSizeChange={handlePageSizeChange}
              />
            </div>

            {/* Audit Log */}
            <div className="xl:col-span-1">
              <UserAuditLog />
            </div>
          </div>
        </main>
      </div>

      <EditUserModal
        user={selectedUser}
        open={editModalOpen}
        onOpenChange={setEditModalOpen}
        onSave={handleSaveEdit}
      />

      <AddUserModal
        open={addModalOpen}
        onOpenChange={setAddModalOpen}
        onAdd={handleAddUser}
      />

      <AlertDialog open={bulkDeleteOpen} onOpenChange={setBulkDeleteOpen}>
        <AlertDialogContent className="bg-card border-border">
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Selected Users</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete {selectedUsers.size} user(s)? This action cannot be undone and will remove all associated data.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="bg-muted/30 border-border/50">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleBulkDelete}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete All
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
};

export default UserManagement;
