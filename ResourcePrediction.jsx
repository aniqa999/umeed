import { useState, useEffect, useCallback, useMemo } from "react";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { ResourcePredictionFilters } from "../components/resources/ResourcePredictionFilters";
import { ResourcePredictionsTable } from "../components/resources/ResourcePredictionsTable";
import { ResourcePredictionDetailsModal } from "../components/resources/ResourcePredictionDetailsModal";
import { ResourcePredictionExport } from "../components/resources/ResourcePredictionExport";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Utensils, Droplets, Stethoscope, Home, Package, Truck, RefreshCw, AlertCircle } from "lucide-react";
import { useToast } from "../hooks/use-toast";
import { useAuth } from "../context/AuthContext";
import { getResources } from "../lib/api";

// Sum all numeric values of a plain object (handles nested resource objects like
// { tents: 113, tarpaulins: 1522 } → 235)
function sumObject(obj) {
  if (obj == null) return 0;
  if (typeof obj === "number") return obj;
  return Object.values(obj).reduce((acc, v) => acc + (typeof v === "number" ? v : 0), 0);
}

// Normalize a resource record from the backend into the UI shape
// expected by ResourcePredictionsTable / ResourcePredictionDetailsModal
function normalizeResource(r) {
  const disaster = r.disasterId ?? {};

  // shelter: { tents, tarpaulins }  → total units
  const shelterTotal   = sumObject(r.shelter);
  // nfi: { kitchen_sets, jerry_cans, blankets, plastic_mats } → total items
  const nfiTotal       = sumObject(r.nfi);
  // health: { iehk_kits } → total kits
  const healthTotal    = sumObject(r.health);
  // sanitation: { latrines } → total units
  const sanitationTotal = sumObject(r.sanitation);

  return {
    id: r._id ?? r.id,
    disasterType: disaster.disasterType ?? "Unknown",
    region: disaster.province ?? r.region ?? "Unknown",
    affectedPopulation: r.affected_population ?? 0,
    timestamp: disaster.startDate ? new Date(disaster.startDate) : new Date(r.updatedAt ?? Date.now()),
    confidenceScore: 0, // not returned by the API
    status: "generated", // resources are already calculated; no approval workflow
    resources: {
      food: {
        required: r.food_kg ?? 0,
        unit: "kg",
        priority: "high",
        confidence: 0,
      },
      water: {
        required: r.water_liters ?? 0,
        unit: "Liters",
        priority: "critical",
        confidence: 0,
      },
      medicalKits: {
        required: healthTotal,
        unit: "IEHK kits",
        priority: "high",
        confidence: 0,
      },
      shelters: {
        required: shelterTotal,
        unit: "Tents/Tarpaulins",
        priority: "high",
        confidence: 0,
      },
      nfi: {
        required: nfiTotal,
        unit: "Items",
        priority: "medium",
        confidence: 0,
      },
      sanitation: {
        required: sanitationTotal,
        unit: "Latrines",
        priority: "medium",
        confidence: 0,
      },
    },
    // Keep raw nested data for the details modal
    rawShelter:   r.shelter   ?? {},
    rawNfi:       r.nfi       ?? {},
    rawHealth:    r.health    ?? {},
    rawSanitation: r.sanitation ?? {},
    logistics: r.logistics ?? {},
    households: r.households ?? 0,
    food_tons: r.food_tons ?? 0,
    disasterTitle: disaster.title ?? "—",
    disasterStatus: disaster.status ?? "—",
    disasterSeverity: disaster.severity ?? "—",
    // Raw _id for API calls
    _id: r._id ?? r.id,
  };
}

export default function ResourcePredictionPage() {
  const { token } = useAuth();
  const { toast } = useToast();

  const [predictions, setPredictions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState("");
  const [activeFilters, setActiveFilters] = useState({});
  const [selectedPrediction, setSelectedPrediction] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);

  const fetchResources = useCallback(async () => {
    setLoading(true);
    setFetchError("");
    try {
      const data = await getResources(token, { limit: 100 });
      const list = data.data ?? [];
      setPredictions(list.map(normalizeResource));
    } catch (err) {
      setFetchError(err.message || "Failed to load resources.");
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    fetchResources();
  }, [fetchResources]);

  // Client-side filtering
  const filteredPredictions = useMemo(() => {
    let list = [...predictions];
    const f = activeFilters;
    if (f.dateFrom) list = list.filter((p) => p.timestamp >= f.dateFrom);
    if (f.dateTo)   list = list.filter((p) => p.timestamp <= f.dateTo);
    if (f.region && f.region !== "All Regions")
      list = list.filter((p) => p.region === f.region);
    if (f.disasterType && f.disasterType !== "All Types")
      list = list.filter((p) => p.disasterType === f.disasterType);
    return list;
  }, [predictions, activeFilters]);

  const handleFilterChange = (filters) => setActiveFilters(filters);

  const handleView = (prediction) => {
    setSelectedPrediction(prediction);
    setDetailsOpen(true);
  };

  // No approval workflow in the API spec for resources — show informational toast
  const handleApprove = (id) => {
    toast({
      title: "Resource Acknowledged",
      description: `Resource record ${id} has been acknowledged.`,
    });
  };

  // Derived stats
  const totals = useMemo(() => ({
    food:       filteredPredictions.reduce((acc, p) => acc + p.resources.food.required, 0),
    water:      filteredPredictions.reduce((acc, p) => acc + p.resources.water.required, 0),
    medical:    filteredPredictions.reduce((acc, p) => acc + p.resources.medicalKits.required, 0),
    shelters:   filteredPredictions.reduce((acc, p) => acc + p.resources.shelters.required, 0),
    pending:    filteredPredictions.filter((p) => p.status === "pending").length,
    dispatched: filteredPredictions.filter((p) => p.status === "dispatched").length,
  }), [filteredPredictions]);

  const formatNumber = (num) => {
    if (num >= 1_000_000) return `${(num / 1_000_000).toFixed(1)}M`;
    if (num >= 1_000)     return `${(num / 1_000).toFixed(0)}K`;
    return num.toLocaleString();
  };

  return (
    <div className="flex min-h-screen w-full bg-background">
      <AppSidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 p-6 overflow-auto space-y-6">
          {/* Page Title */}
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold">Resource Allocation</h1>
              <p className="text-muted-foreground mt-1">
                Calculated resource requirements for disaster response
              </p>
            </div>
            <div className="flex items-center gap-3">
              <Button
                variant="outline"
                className="gap-2"
                onClick={fetchResources}
                disabled={loading}
              >
                <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
                Refresh
              </Button>
              <ResourcePredictionExport predictions={filteredPredictions} />
            </div>
          </div>

          {/* Error Banner */}
          {fetchError && (
            <div className="flex items-center gap-3 p-4 rounded-xl bg-destructive/10 border border-destructive/20 text-destructive">
              <AlertCircle className="w-5 h-5 shrink-0" />
              <p className="text-sm flex-1">{fetchError}</p>
              <Button size="sm" variant="outline" onClick={fetchResources} className="border-destructive/30 text-destructive hover:bg-destructive/10">
                Retry
              </Button>
            </div>
          )}

          {/* Stats Cards */}
          <div className="grid grid-cols-2 md:grid-cols-6 gap-4">
            <Card className="bg-card border-border">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Food Required</CardTitle>
                <Utensils className="h-4 w-4 text-orange-400" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-orange-400">{loading ? "…" : formatNumber(totals.food)}</div>
                <p className="text-xs text-muted-foreground">kg food</p>
              </CardContent>
            </Card>

            <Card className="bg-card border-border">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Water Required</CardTitle>
                <Droplets className="h-4 w-4 text-blue-400" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-blue-400">{loading ? "…" : formatNumber(totals.water)}</div>
                <p className="text-xs text-muted-foreground">Liters</p>
              </CardContent>
            </Card>

            <Card className="bg-card border-border">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Health Units</CardTitle>
                <Stethoscope className="h-4 w-4 text-red-400" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-red-400">{loading ? "…" : formatNumber(totals.medical)}</div>
                <p className="text-xs text-muted-foreground">Units</p>
              </CardContent>
            </Card>

            <Card className="bg-card border-border">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Shelters</CardTitle>
                <Home className="h-4 w-4 text-emerald-400" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-emerald-400">{loading ? "…" : formatNumber(totals.shelters)}</div>
                <p className="text-xs text-muted-foreground">Units</p>
              </CardContent>
            </Card>

            <Card className="bg-card border-border">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Records</CardTitle>
                <Package className="h-4 w-4 text-amber-400" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-amber-400">{loading ? "…" : filteredPredictions.length}</div>
                <p className="text-xs text-muted-foreground">Disaster records</p>
              </CardContent>
            </Card>

            <Card className="bg-card border-border">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Dispatched</CardTitle>
                <Truck className="h-4 w-4 text-primary" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-primary">{loading ? "…" : totals.dispatched}</div>
                <p className="text-xs text-muted-foreground">In transit</p>
              </CardContent>
            </Card>
          </div>

          {/* Filters */}
          <ResourcePredictionFilters onFilterChange={handleFilterChange} />

          {/* Loading */}
          {loading && (
            <div className="flex justify-center py-12 text-muted-foreground text-sm">
              Loading resources…
            </div>
          )}

          {/* Table */}
          {!loading && (
            <ResourcePredictionsTable
              predictions={filteredPredictions}
              onView={handleView}
              onApprove={handleApprove}
            />
          )}

          {/* Details Modal */}
          <ResourcePredictionDetailsModal
            prediction={selectedPrediction}
            open={detailsOpen}
            onOpenChange={setDetailsOpen}
            onApprove={handleApprove}
          />
        </main>
      </div>
    </div>
  );
}
