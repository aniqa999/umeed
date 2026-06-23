import { useState, useEffect, useCallback, useMemo } from "react";
import { SidebarProvider, SidebarInset } from "../components/ui/sidebar";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { DisasterFilters } from "../components/disasters/DisasterFilters";
import { DisastersTable } from "../components/disasters/DisastersTable";
import { DisasterDetailsModal } from "../components/disasters/DisasterDetailsModal";
import { DisasterMapView } from "../components/disasters/DisasterMapView";
import { WeatherPanel } from "../components/disasters/WeatherPanel";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import {
  AlertTriangle, Activity, CheckCircle, Clock,
  Users, MapPin, Map, List, RefreshCw, AlertCircle,
} from "lucide-react";
import { Button } from "../components/ui/button";
import { useToast } from "../hooks/use-toast";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { getDisastersWithResources, updateDisaster, deleteDisaster } from "../lib/api";

// Map API status values → normalised UI status tokens
const STATUS_MAP = {
  active:     "active",
  ongoing:    "active",
  open:       "active",
  monitoring: "monitoring",
  watch:      "monitoring",
  contained:  "contained",
  controlled: "contained",
  resolved:   "resolved",
  closed:     "resolved",
  completed:  "resolved",
};

// Map API severity values → normalised UI severity tokens
const SEVERITY_MAP = {
  low:      "low",
  minor:    "low",
  medium:   "medium",
  moderate: "medium",
  high:     "high",
  critical: "critical",
  severe:   "critical",
  extreme:  "critical",
};

// Normalize a backend disaster (from /api/resources/disasters) to the UI shape
function normalizeDisaster(d) {
  const impact = d.impact ?? {};
  const coords = d.location?.coordinates; // [lng, lat]
  const rawStatus   = (d.status   ?? "active").toLowerCase();
  const rawSeverity = (d.severity ?? "medium").toLowerCase();

  return {
    id: d._id ?? d.id,
    name: d.title ?? "Unnamed Disaster",
    type: d.disasterType ?? "Unknown",
    region: d.province ?? d.region ?? "",
    district: d.district ?? "",
    severity: SEVERITY_MAP[rawSeverity] ?? rawSeverity,
    status: STATUS_MAP[rawStatus] ?? rawStatus,
    startDate: d.startDate ? new Date(d.startDate) : new Date(),
    endDate: d.endDate ? new Date(d.endDate) : null,
    affectedPopulation: impact.affected_population ?? 0,
    casualties: impact.deaths ?? 0,
    displaced: impact.displaced ?? 0,
    responseProgress: d.responseProgress ?? 0,
    lastUpdate: d.updatedAt ?? d.startDate ?? new Date().toISOString(),
    coordinates: coords ? { lat: coords[1], lng: coords[0] } : { lat: 30.3753, lng: 69.3451 },
    description: d.description ?? "",
    impact,
    technicalData: d.technicalData ?? {},
    resources: d.resources ?? null,
    // Raw id for API calls
    _id: d._id ?? d.id,
  };
}

export default function DisastersPage() {
  const { token } = useAuth();
  const { toast } = useToast();
  const navigate = useNavigate();

  const [disasters, setDisasters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState("");
  const [activeFilters, setActiveFilters] = useState({});
  const [selectedDisaster, setSelectedDisaster] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);

  const fetchDisasters = useCallback(async () => {
    setLoading(true);
    setFetchError("");
    try {
      const data = await getDisastersWithResources(token);
      const list = data.data ?? [];
      setDisasters(list.map(normalizeDisaster));
    } catch (err) {
      setFetchError(err.message || "Failed to load disasters.");
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    fetchDisasters();
  }, [fetchDisasters]);

  // Client-side filtering
  const filteredDisasters = useMemo(() => {
    let list = [...disasters];
    const f = activeFilters;

    if (f.dateFrom) list = list.filter((d) => d.startDate >= f.dateFrom);
    if (f.dateTo)   list = list.filter((d) => d.startDate <= f.dateTo);
    if (f.region && f.region !== "All Regions")
      list = list.filter((d) => d.region === f.region);
    if (f.disasterType && f.disasterType !== "All Types")
      list = list.filter((d) => d.type === f.disasterType);
    if (f.severity && f.severity !== "All Severities")
      list = list.filter((d) => d.severity === f.severity.toLowerCase());
    if (f.status && f.status !== "All Status")
      list = list.filter((d) => d.status === f.status.toLowerCase());

    return list;
  }, [disasters, activeFilters]);

  const handleFilterChange = (filters) => setActiveFilters(filters);

  const handleView = (disaster) => {
    setSelectedDisaster(disaster);
    setDetailsOpen(true);
  };

  const handleCreateAlert = (disaster) => {
    toast({ title: "Redirecting to Alerts", description: `Creating alert for ${disaster.name}` });
    navigate("/alerts");
  };

  const handleGenerateReport = (disaster) => {
    toast({ title: "Redirecting to Reports", description: `Generating report for ${disaster.name}` });
    navigate("/reports");
  };

  const handleUpdateDisaster = async (id, body) => {
    try {
      const data = await updateDisaster(token, id, body);
      const updated = normalizeDisaster(data.disaster);
      setDisasters((prev) => prev.map((d) => d._id === id ? updated : d));
      toast({ title: "Disaster updated", description: "Changes saved successfully." });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  const handleDeleteDisaster = async (id) => {
    try {
      await deleteDisaster(token, id);
      setDisasters((prev) => prev.filter((d) => d._id !== id));
      toast({ title: "Disaster deleted", description: "The disaster record has been removed." });
    } catch (err) {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    }
  };

  // Stats derived from all loaded disasters (not filtered)
  const stats = useMemo(() => ({
    active:       disasters.filter((d) => d.status === "active").length,
    monitoring:   disasters.filter((d) => d.status === "monitoring").length,
    contained:    disasters.filter((d) => d.status === "contained").length,
    resolved:     disasters.filter((d) => d.status === "resolved").length,
    totalAffected: disasters
      .filter((d) => d.status === "active" || d.status === "monitoring")
      .reduce((acc, d) => acc + d.affectedPopulation, 0),
    regionsAffected: new Set(
      disasters
        .filter((d) => d.status === "active" || d.status === "monitoring")
        .map((d) => d.region)
    ).size,
  }), [disasters]);

  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full bg-background">
        <AppSidebar />
        <SidebarInset className="flex-1">
          <Header />
          <main className="p-6 space-y-6">
            {/* Page Title */}
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-3xl font-bold">Disaster Management</h1>
                <p className="text-muted-foreground mt-1">
                  Monitor active and historical disasters across Pakistan
                </p>
              </div>
              <Button
                variant="outline"
                className="gap-2"
                onClick={fetchDisasters}
                disabled={loading}
              >
                <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
                Refresh
              </Button>
            </div>

            {/* Error Banner */}
            {fetchError && (
              <div className="flex items-center gap-3 p-4 rounded-xl bg-destructive/10 border border-destructive/20 text-destructive">
                <AlertCircle className="w-5 h-5 shrink-0" />
                <p className="text-sm flex-1">{fetchError}</p>
                <Button size="sm" variant="outline" onClick={fetchDisasters} className="border-destructive/30 text-destructive hover:bg-destructive/10">
                  Retry
                </Button>
              </div>
            )}

            {/* Stats Cards */}
            <div className="grid grid-cols-2 md:grid-cols-6 gap-4">
              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Active</CardTitle>
                  <AlertTriangle className="h-4 w-4 text-red-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-red-400">{loading ? "…" : stats.active}</div>
                  <p className="text-xs text-muted-foreground">Requiring response</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Monitoring</CardTitle>
                  <Activity className="h-4 w-4 text-amber-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-amber-400">{loading ? "…" : stats.monitoring}</div>
                  <p className="text-xs text-muted-foreground">Under observation</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Contained</CardTitle>
                  <Clock className="h-4 w-4 text-blue-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-blue-400">{loading ? "…" : stats.contained}</div>
                  <p className="text-xs text-muted-foreground">Under control</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Resolved</CardTitle>
                  <CheckCircle className="h-4 w-4 text-emerald-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-emerald-400">{loading ? "…" : stats.resolved}</div>
                  <p className="text-xs text-muted-foreground">Completed response</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Total Affected</CardTitle>
                  <Users className="h-4 w-4 text-primary" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {loading ? "…" : stats.totalAffected >= 1_000_000
                      ? `${(stats.totalAffected / 1_000_000).toFixed(1)}M`
                      : stats.totalAffected >= 1_000
                        ? `${(stats.totalAffected / 1_000).toFixed(0)}K`
                        : stats.totalAffected.toLocaleString()}
                  </div>
                  <p className="text-xs text-muted-foreground">Active disasters</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Regions</CardTitle>
                  <MapPin className="h-4 w-4 text-primary" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{loading ? "…" : stats.regionsAffected}</div>
                  <p className="text-xs text-muted-foreground">Currently affected</p>
                </CardContent>
              </Card>
            </div>

            {/* Weather Panel */}
            <WeatherPanel disasters={filteredDisasters} />

            {/* Filters */}
            <DisasterFilters onFilterChange={handleFilterChange} />

            {/* Loading state */}
            {loading && (
              <div className="flex justify-center py-12 text-muted-foreground text-sm">
                Loading disasters…
              </div>
            )}

            {/* Map and Table Views */}
            {!loading && (
              <Tabs defaultValue="map" className="space-y-4">
                <TabsList>
                  <TabsTrigger value="map" className="gap-2">
                    <Map className="h-4 w-4" />
                    Map View
                  </TabsTrigger>
                  <TabsTrigger value="table" className="gap-2">
                    <List className="h-4 w-4" />
                    Table View
                  </TabsTrigger>
                </TabsList>

                <TabsContent value="map">
                  <DisasterMapView
                    disasters={filteredDisasters}
                    onViewDisaster={handleView}
                  />
                </TabsContent>

                <TabsContent value="table">
                  <DisastersTable
                    disasters={filteredDisasters}
                    onView={handleView}
                    onCreateAlert={handleCreateAlert}
                    onGenerateReport={handleGenerateReport}
                    onUpdate={handleUpdateDisaster}
                    onDelete={handleDeleteDisaster}
                  />
                </TabsContent>
              </Tabs>
            )}

            {/* Details Modal */}
            <DisasterDetailsModal
              disaster={selectedDisaster}
              open={detailsOpen}
              onOpenChange={setDetailsOpen}
              onCreateAlert={handleCreateAlert}
              onGenerateReport={handleGenerateReport}
            />
          </main>
        </SidebarInset>
      </div>
    </SidebarProvider>
  );
}
