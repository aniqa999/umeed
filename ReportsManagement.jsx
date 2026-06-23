import { useState, useMemo, useEffect, useCallback } from "react";
import { Download, RefreshCw, AlertCircle } from "lucide-react";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { ReportTable } from "../components/reports/ReportTable";
import { ReportFilters } from "../components/reports/ReportFilters";
import { ReportStatsCards } from "../components/reports/ReportStatsCards";
import { ReportPreviewModal } from "../components/reports/ReportPreviewModal";
import { ReportGenerationStatus } from "../components/reports/ReportGenerationStatus";
import { GenerateReportModal } from "../components/reports/GenerateReportModal";
import { Button } from "../components/ui/button";
import { toast } from "../hooks/use-toast";
import { useAuth } from "../context/AuthContext";
import { getReports, archiveReport, deleteReport } from "../lib/api";

// Normalize backend report shape to the UI shape expected by ReportTable
function normalizeReport(r) {
  const disaster = r.disasterId ?? {};
  return {
    id: r._id ?? r.id,
    title: r.title ?? "Untitled Report",
    disaster: disaster.title ?? "—",
    disasterType: (disaster.disasterType ?? "").toLowerCase(),
    region: disaster.province ?? "—",
    generatedBy: r.generatedBy?.fullName ?? r.generatedBy?.email ?? "System",
    generatedAt: r.createdAt ?? new Date().toISOString(),
    status: r.status === "archived" ? "archived" : "ready",
    reportNumber: r.reportNumber ?? "",
    notes: r.notes ?? "",
    downloadCount: r.downloadCount ?? 0,
    // Raw id for API calls
    _id: r._id ?? r.id,
  };
}

const ReportsManagement = () => {
  const { token } = useAuth();

  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [typeFilter, setTypeFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const [previewOpen, setPreviewOpen] = useState(false);
  const [generateOpen, setGenerateOpen] = useState(false);
  const [selectedReport, setSelectedReport] = useState(null);

  const fetchReports = useCallback(async () => {
    setLoading(true);
    setFetchError("");
    try {
      const data = await getReports(token, { limit: 100 });
      const list = data.data ?? [];
      setReports(list.map(normalizeReport));
    } catch (err) {
      setFetchError(err.message || "Failed to load reports.");
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    fetchReports();
  }, [fetchReports]);

  // Client-side filtering
  const filteredReports = useMemo(() => {
    return reports.filter((report) => {
      const matchesSearch =
        report.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        report.disaster.toLowerCase().includes(searchQuery.toLowerCase()) ||
        report.region.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesType = typeFilter === "all" || report.disasterType === typeFilter;
      const matchesStatus = statusFilter === "all" || report.status === statusFilter;
      return matchesSearch && matchesType && matchesStatus;
    });
  }, [reports, searchQuery, typeFilter, statusFilter]);

  // Stats
  const stats = useMemo(() => ({
    total: reports.length,
    ready: reports.filter((r) => r.status === "ready").length,
    generating: reports.filter((r) => r.status === "generating").length,
    archived: reports.filter((r) => r.status === "archived").length,
  }), [reports]);

  const handleView = (report) => {
    setSelectedReport(report);
    setPreviewOpen(true);
  };

  const handleDownload = (report, format) => {
    toast({
      title: "Download started",
      description: `Downloading ${report.title} as ${format?.toUpperCase() ?? "PDF"}…`,
    });
  };

  const handleArchive = async (reportId) => {
    const report = reports.find((r) => r.id === reportId);
    if (!report) return;
    try {
      await archiveReport(token, report._id);
      setReports((prev) => prev.map((r) => r.id === reportId ? { ...r, status: "archived" } : r));
      toast({ title: "Report archived", description: "The report has been moved to archives." });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  const handleDelete = async (reportId) => {
    const report = reports.find((r) => r.id === reportId);
    if (!report) return;
    try {
      await deleteReport(token, report._id);
      setReports((prev) => prev.filter((r) => r.id !== reportId));
      toast({ title: "Report deleted", description: "The report has been permanently deleted." });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  // GenerateReportModal calls back with form data; after saving we refresh
  const handleGenerateReport = async () => {
    toast({ title: "Report queued", description: "Your report has been queued for generation." });
    // Re-fetch after a moment to pick up the new record
    setTimeout(fetchReports, 2000);
  };

  const clearFilters = () => {
    setSearchQuery("");
    setTypeFilter("all");
    setStatusFilter("all");
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
              <h1 className="text-2xl font-bold text-foreground">Reports Management</h1>
              <p className="text-muted-foreground">Generate and manage official disaster reports</p>
            </div>
            <div className="flex gap-3">
              <Button
                variant="outline"
                className="gap-2 border-border/50 bg-muted/30"
                onClick={fetchReports}
                disabled={loading}
              >
                <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
                Refresh
              </Button>
              <Button variant="outline" className="gap-2 border-border/50 bg-muted/30">
                <Download className="w-4 h-4" />
                Export All
              </Button>
              <Button
                className="gap-2 bg-primary text-primary-foreground hover:bg-primary/90"
                onClick={() => setGenerateOpen(true)}
              >
                Generate Report
              </Button>
            </div>
          </div>

          {/* Error Banner */}
          {fetchError && (
            <div className="flex items-center gap-3 p-4 mb-6 rounded-xl bg-destructive/10 border border-destructive/20 text-destructive">
              <AlertCircle className="w-5 h-5 shrink-0" />
              <p className="text-sm flex-1">{fetchError}</p>
              <Button size="sm" variant="outline" onClick={fetchReports} className="border-destructive/30 text-destructive hover:bg-destructive/10">
                Retry
              </Button>
            </div>
          )}

          {/* Stats Cards */}
          <ReportStatsCards
            totalReports={stats.total}
            readyReports={stats.ready}
            generatingReports={stats.generating}
            archivedReports={stats.archived}
          />

          {/* Generation Status (only shown when tasks exist) */}
          <ReportGenerationStatus tasks={[]} />

          {/* Filters */}
          <ReportFilters
            searchQuery={searchQuery}
            onSearchChange={setSearchQuery}
            typeFilter={typeFilter}
            onTypeChange={setTypeFilter}
            statusFilter={statusFilter}
            onStatusChange={setStatusFilter}
            onClearFilters={clearFilters}
          />

          {/* Loading */}
          {loading && (
            <div className="flex justify-center py-12 text-muted-foreground text-sm">
              Loading reports…
            </div>
          )}

          {/* Report Table */}
          {!loading && (
            <ReportTable
              reports={filteredReports}
              onView={handleView}
              onDownload={handleDownload}
              onArchive={handleArchive}
              onDelete={handleDelete}
            />
          )}
        </main>
      </div>

      <ReportPreviewModal
        report={selectedReport}
        open={previewOpen}
        onOpenChange={setPreviewOpen}
        onDownload={handleDownload}
      />

      <GenerateReportModal
        open={generateOpen}
        onOpenChange={setGenerateOpen}
        onGenerate={handleGenerateReport}
      />
    </div>
  );
};

export default ReportsManagement;
