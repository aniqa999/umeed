import { useState, useEffect } from "react";
import { SidebarProvider } from "../components/ui/sidebar";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { Badge } from "../components/ui/badge";
import { Switch } from "../components/ui/switch";
import { Separator } from "../components/ui/separator";
import { AvatarUpload, useStoredAvatar } from "../components/profile/AvatarUpload";
import { ChangePasswordModal } from "../components/profile/ChangePasswordModal";
import { ActiveSessionsModal } from "../components/profile/ActiveSessionsModal";
import {
    User,
    Mail,
    Phone,
    MapPin,
    Shield,
    Bell,
    Key,
    Calendar,
    Clock,
    Activity,
    FileText,
    AlertTriangle,
    CheckCircle,
    Edit,
    Save,
    Loader2
} from "lucide-react";
import { useToast } from "../hooks/use-toast";
import { useAuth } from "../context/AuthContext";

const BASE_URL = import.meta.env.VITE_API_BASE_URL;

function authHeaders(token) {
    return {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
    };
}

async function request(path, token, options = {}) {
    const res = await fetch(`${BASE_URL}${path}`, {
        ...options,
        headers: { ...authHeaders(token), ...(options.headers ?? {}) },
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) {
        throw new Error(data.message || data.error || `Server error ${res.status}`);
    }
    return data;
}

const getCurrentUser = async (token) => {
    return request("/api/auth/me", token);
};

const recentActivity = [
    { id: 1, action: "Updated disaster report", type: "report", time: "2 hours ago", icon: FileText },
    { id: 2, action: "Approved user registration", type: "user", time: "4 hours ago", icon: User },
    { id: 3, action: "Sent emergency alert", type: "alert", time: "Yesterday", icon: AlertTriangle },
    { id: 4, action: "Generated monthly report", type: "report", time: "2 days ago", icon: FileText },
    { id: 5, action: "Updated security settings", type: "security", time: "3 days ago", icon: Shield },
];

const ProfilePage = () => {
    const { toast } = useToast();
    const { user: authUser, token, updateUser } = useAuth();
    const { getStoredAvatar } = useStoredAvatar();
    const [isEditing, setIsEditing] = useState(false);
    const [profile, setProfile] = useState(null);
    const [loading, setLoading] = useState(true);
    // const [updating, setUpdating] = useState(false);
    const [showPasswordModal, setShowPasswordModal] = useState(false);   
    const [showSessionsModal, setShowSessionsModal] = useState(false);

    useEffect(() => {
        async function loadUserData() {
            if (!token) {
                setLoading(false);
                return;
            }

            try {
                setLoading(true);
                const response = await getCurrentUser(token);
                if (response.success && response.user) {
                    const userData = response.user;

                    const profileData = {
                        id: userData._id || userData.id,
                        name: userData.fullName || userData.name,
                        email: userData.email,
                        phone: userData.phone || "",
                        role: userData.role === "government" ? "Government Official" :
                            userData.role === "ngo" ? "NGO Coordinator" :
                                userData.role === "admin" ? "Administrator" :
                                    userData.role || "User",
                        department: userData.organization || userData.department || "",
                        region: userData.province || userData.region || "",
                        joinDate: userData.createdAt || userData.joinDate || new Date().toISOString(),
                        lastLogin: userData.lastLogin ? new Date(userData.lastLogin).toLocaleString() : "Never",
                        avatar: userData.avatar || "",
                        status: userData.status || "active",
                    };

                    setProfile(profileData);
                }
            } catch (error) {
                console.error("Failed to load user profile:", error);
                toast({
                    title: "Error",
                    description: "Failed to load profile data. Please try again.",
                    variant: "destructive",
                });
            } finally {
                setLoading(false);
            }
        }

        loadUserData();
    }, [token, toast]);

    useEffect(() => {
        if (!profile) return;

        function loadAvatar() {
            const storedAvatar = getStoredAvatar();
            if (storedAvatar) {
                setProfile(prev => prev ? ({ ...prev, avatar: storedAvatar }) : prev);
            }
        }
        loadAvatar();
    }, [getStoredAvatar, profile]);

    const handleAvatarChange = (avatarUrl) => {
        setProfile(prev => prev ? ({ ...prev, avatar: avatarUrl }) : prev);
    };
    

    if (loading) {
        return (
            <SidebarProvider>
                <div className="min-h-screen flex w-full bg-background">
                    <AppSidebar />
                    <div className="flex-1 flex flex-col">
                        <Header />
                        <main className="flex-1 p-6 flex items-center justify-center">
                            <div className="text-center">
                                <Loader2 className="h-8 w-8 animate-spin mx-auto mb-4 text-primary" />
                                <p className="text-muted-foreground">Loading profile...</p>
                            </div>
                        </main>
                    </div>
                </div>
            </SidebarProvider>
        );
    }

    if (!profile) {
        return (
            <SidebarProvider>
                <div className="min-h-screen flex w-full bg-background">
                    <AppSidebar />
                    <div className="flex-1 flex flex-col">
                        <Header />
                        <main className="flex-1 p-6 flex items-center justify-center">
                            <div className="text-center">
                                <AlertTriangle className="h-12 w-12 mx-auto mb-4 text-destructive" />
                                <h2 className="text-xl font-semibold mb-2">Unable to Load Profile</h2>
                                <p className="text-muted-foreground">Please try refreshing the page.</p>
                            </div>
                        </main>
                    </div>
                </div>
            </SidebarProvider>
        );
    }

    return (
        <SidebarProvider>
            <div className="min-h-screen flex w-full bg-background">
                <AppSidebar />
                <div className="flex-1 flex flex-col">
                    <Header />
                    <main className="flex-1 p-6 overflow-auto">
                        <div className="max-w-6xl mx-auto space-y-6">
                            {/* Page Header */}
                            <div>
                                <h1 className="text-3xl font-bold text-foreground">Profile</h1>
                                <p className="text-muted-foreground mt-1">Manage your account settings and preferences</p>
                            </div>

                            <Tabs defaultValue="profile" className="space-y-6">
                                <TabsList className="bg-muted/50">
                                    <TabsTrigger value="profile" className="gap-2">
                                        <User className="h-4 w-4" />
                                        Profile
                                    </TabsTrigger>
                                    <TabsTrigger value="security" className="gap-2">
                                        <Shield className="h-4 w-4" />
                                        Security
                                    </TabsTrigger>                                    
                                    <TabsTrigger value="activity" className="gap-2">
                                        <Activity className="h-4 w-4" />
                                        Activity
                                    </TabsTrigger>
                                </TabsList>

                                {/* Profile Tab */}
                                <TabsContent value="profile" className="space-y-6">
                                    <Card>
                                        <CardHeader className="flex flex-row items-center justify-between">
                                            <div>
                                                <CardTitle>Personal Information</CardTitle>
                                                <CardDescription>Update your personal details and contact information</CardDescription>
                                            </div>                                            
                                        </CardHeader>
                                        <CardContent className="space-y-6">
                                            {/* Avatar Section */}
                                            <div className="flex items-center gap-6">
                                                <AvatarUpload
                                                    currentAvatar={profile.avatar}
                                                    name={profile.name}
                                                    isEditing={isEditing}
                                                    onAvatarChange={handleAvatarChange}
                                                />
                                                <div className={isEditing ? "ml-auto" : ""}>
                                                    <p className="text-muted-foreground">{profile.role}</p>
                                                    <Badge variant="outline" className="mt-2">
                                                        <CheckCircle className="h-3 w-3 mr-1 text-green-500" />
                                                        {profile.status === "active" ? "Active" : profile.status}
                                                    </Badge>
                                                </div>
                                            </div>

                                            <Separator />

                                            {/* Form Fields */}
                                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                                <div className="space-y-2">
                                                    <Label htmlFor="name">Full Name</Label>
                                                    <div className="relative">
                                                        <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                                                        <Input
                                                            id="name"
                                                            value={profile.name}
                                                            onChange={(e) => setProfile(p => ({ ...p, name: e.target.value }))}
                                                            disabled={!isEditing}
                                                            className="pl-10"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="space-y-2">
                                                    <Label htmlFor="email">Email Address</Label>
                                                    <div className="relative">
                                                        <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                                                        <Input
                                                            id="email"
                                                            type="email"
                                                            value={profile.email}
                                                            disabled={true}
                                                            className="pl-10 bg-muted"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="space-y-2">
                                                    <Label htmlFor="phone">Phone Number</Label>
                                                    <div className="relative">
                                                        <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                                                        <Input
                                                            id="phone"
                                                            value={profile.phone}
                                                            onChange={(e) => setProfile(p => ({ ...p, phone: e.target.value }))}
                                                            disabled={!isEditing}
                                                            className="pl-10"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="space-y-2">
                                                    <Label htmlFor="region">Province / Region</Label>
                                                    <div className="relative">
                                                        <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                                                        <Input
                                                            id="region"
                                                            value={profile.region}
                                                            onChange={(e) => setProfile(p => ({ ...p, region: e.target.value }))}
                                                            disabled={!isEditing}
                                                            className="pl-10"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="space-y-2">
                                                    <Label htmlFor="department">Organization / Department</Label>
                                                    <Input
                                                        id="department"
                                                        value={profile.department}
                                                        onChange={(e) => setProfile(p => ({ ...p, department: e.target.value }))}
                                                        disabled={!isEditing}
                                                    />
                                                </div>

                                                <div className="space-y-2">
                                                    <Label htmlFor="role">Role</Label>
                                                    <Input
                                                        id="role"
                                                        value={profile.role}
                                                        disabled
                                                        className="bg-muted"
                                                    />
                                                </div>
                                            </div>

                                            <Separator />

                                            {/* Account Info */}
                                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                <div className="flex items-center gap-3 p-4 rounded-lg bg-muted/50">
                                                    <Calendar className="h-5 w-5 text-muted-foreground" />
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">Member Since</p>
                                                        <p className="font-medium text-foreground">{new Date(profile.joinDate).toLocaleDateString()}</p>
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-3 p-4 rounded-lg bg-muted/50">
                                                    <Clock className="h-5 w-5 text-muted-foreground" />
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">Last Login</p>
                                                        <p className="font-medium text-foreground">{profile.lastLogin}</p>
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-3 p-4 rounded-lg bg-muted/50">
                                                    <Shield className="h-5 w-5 text-muted-foreground" />
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">User ID</p>
                                                        <p className="font-medium text-foreground">{profile.id}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardContent>
                                    </Card>
                                </TabsContent>

                                {/* Security Tab */}
                                <TabsContent value="security" className="space-y-6">
                                    <Card>
                                        <CardHeader>
                                            <CardTitle>Password & Authentication</CardTitle>
                                            <CardDescription>Manage your password and security settings</CardDescription>
                                        </CardHeader>
                                        <CardContent className="space-y-6">
                                            <div className="space-y-4">
                                                <div className="flex items-center justify-between p-4 rounded-lg border border-border">
                                                    <div className="flex items-center gap-4">
                                                        <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                                                            <Key className="h-5 w-5 text-primary" />
                                                        </div>
                                                        <div>
                                                            <p className="font-medium text-foreground">Password</p>
                                                            <p className="text-sm text-muted-foreground">Change your password</p>
                                                        </div>
                                                    </div>
                                                    <Button variant="outline" onClick={() => setShowPasswordModal(true)}>Change Password</Button>
                                                </div>

                                                <div className="flex items-center justify-between p-4 rounded-lg border border-border">
                                                    <div className="flex items-center gap-4">
                                                        <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                                                            <Shield className="h-5 w-5 text-primary" />
                                                        </div>
                                                        <div>
                                                            <p className="font-medium text-foreground">Two-Factor Authentication</p>
                                                            <p className="text-sm text-muted-foreground">Add an extra layer of security</p>
                                                        </div>
                                                    </div>
                                                    <Button variant="outline">Enable 2FA</Button>
                                                </div>

                                                <div className="flex items-center justify-between p-4 rounded-lg border border-border">
                                                    <div className="flex items-center gap-4">
                                                        <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                                                            <Activity className="h-5 w-5 text-primary" />
                                                        </div>
                                                        <div>
                                                            <p className="font-medium text-foreground">Active Sessions</p>
                                                            <p className="text-sm text-muted-foreground">Manage your active sessions</p>
                                                        </div>
                                                    </div>
                                                    <Button variant="outline" onClick={() => setShowSessionsModal(true)}>View Sessions</Button>
                                                </div>
                                            </div>
                                        </CardContent>
                                    </Card>
                                </TabsContent>                                                                

                                {/* Activity Tab */}
                                <TabsContent value="activity" className="space-y-6">
                                    <Card>
                                        <CardHeader>
                                            <CardTitle>Recent Activity</CardTitle>
                                            <CardDescription>Your recent actions and system interactions</CardDescription>
                                        </CardHeader>
                                        <CardContent>
                                            <div className="space-y-4">
                                                {recentActivity.map((activity) => (
                                                    <div key={activity.id} className="flex items-center gap-4 p-4 rounded-lg border border-border">
                                                        <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center">
                                                            <activity.icon className="h-5 w-5 text-muted-foreground" />
                                                        </div>
                                                        <div className="flex-1">
                                                            <p className="font-medium text-foreground">{activity.action}</p>
                                                            <p className="text-sm text-muted-foreground">{activity.time}</p>
                                                        </div>
                                                        <Badge variant="secondary">{activity.type}</Badge>
                                                    </div>
                                                ))}
                                            </div>
                                        </CardContent>
                                    </Card>
                                </TabsContent>
                            </Tabs>
                        </div>
                    </main>
                </div>
            </div>

            <ChangePasswordModal
                open={showPasswordModal}
                onOpenChange={setShowPasswordModal}
            />

            <ActiveSessionsModal
                open={showSessionsModal}
                onOpenChange={setShowSessionsModal}
            />
        </SidebarProvider>
    );
};

export default ProfilePage;