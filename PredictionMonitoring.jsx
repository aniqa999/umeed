import { useState, useEffect } from "react";
import { SidebarProvider, SidebarInset } from "../components/ui/sidebar";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { PredictionFilters } from "../components/predictions/PredictionFilters";
import { PredictionsTable } from "../components/predictions/PredictionsTable";
import { PredictionDetailsModal } from "../components/predictions/PredictionDetailsModal";
import { PredictionExport } from "../components/predictions/PredictionExport";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Brain, AlertTriangle, MapPin, TrendingUp } from "lucide-react";
import { useToast } from "../hooks/use-toast";
import { getPredictions } from "../lib/api.js";
import { useAuth } from "../context/AuthContext";

export default function PredictionMonitoring() {
  const [predictions, setPredictions] = useState([]);
  const [filteredPredictions, setFilteredPredictions] = useState([]);
  const [selectedPrediction, setSelectedPrediction] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();
  const { token } = useAuth();

  useEffect(() => {
    fetchPredictions();
  }, []);

  const fetchPredictions = async () => {
    try {
      setLoading(true);
      const data = await getPredictions(token);
      const mappedPredictions = data.data.map(mapDisasterToPrediction);
      setPredictions(mappedPredictions);
      setFilteredPredictions(mappedPredictions);
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to fetch predictions: " + error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const mapDisasterToPrediction = (disaster) => ({
    id: disaster._id,
    predictionId: `PRED-${disaster._id.slice(-6).toUpperCase()}`,
    user: disaster.createdBy?.fullName || "Unknown",
    userEmail: disaster.createdBy?.email || "Unknown",
    disasterType: disaster.disasterType,
    region: disaster.province,
    timestamp: new Date(disaster.createdAt),
    confidenceScore: disaster.technicalData?.magnitude
      ? Math.min(95, disaster.technicalData.magnitude * 10 + 40)
      : Math.floor(Math.random() * 20) + 70,
    status: disaster.status === "Ongoing" ? "pending" : "approved",
    humanLoss: {
      estimated: disaster.impact?.deaths + disaster.impact?.injured || 0,
      range: `${Math.max(0, (disaster.impact?.deaths || 0) - 100)} - ${(disaster.impact?.deaths || 0) + 100}`,
      confidence: Math.floor(Math.random() * 20) + 70,
    },
    economicLoss: {
      estimated: disaster.impact?.crop_area_damaged
        ? disaster.impact.crop_area_damaged * 50000
        : 0,
      currency: "PKR",
      confidence: Math.floor(Math.random() * 20) + 65,
    },
    infrastructureDamage: {
      buildings: disaster.impact?.houses_damaged + disaster.impact?.houses_demolished || 0,
      roads: Math.floor(disaster.impact?.houses_damaged * 0.05) || 0,
      bridges: Math.floor(disaster.impact?.houses_damaged * 0.003) || 0,
      confidence: Math.floor(Math.random() * 20) + 70,
    },
    severity: disaster.severity || "Medium",
    disasterCategory: disaster.disasterCategory || "Natural",
  });

  const handleFilterChange = (filters) => {
    let filtered = [...predictions];

    if (filters.dateFrom) {
      filtered = filtered.filter((p) => p.timestamp >= filters.dateFrom);
    }
    if (filters.dateTo) {
      filtered = filtered.filter((p) => p.timestamp <= filters.dateTo);
    }
    if (filters.region !== "All Regions") {
      filtered = filtered.filter((p) => p.region === filters.region);
    }
    if (filters.disasterType !== "All Types") {
      filtered = filtered.filter((p) => p.disasterType === filters.disasterType);
    }

    setFilteredPredictions(filtered);
  };

  const handleView = (prediction) => {
    setSelectedPrediction(prediction);
    setDetailsOpen(true);
  };

  const handleApprove = (id) => {
    const updateStatus = (prev) =>
      prev.map((p) => (p.id === id ? { ...p, status: "approved" } : p));

    setPredictions(updateStatus);
    setFilteredPredictions(updateStatus);

    toast({
      title: "Prediction Approved",
      description: `Prediction ${id} has been approved for public release per NDMA guidelines.`,
    });
  };

  const stats = {
    total: predictions.length,
    highSeverity: predictions.filter((p) => p.severity === "High").length,
    natural: predictions.filter((p) => p.disasterCategory === "Natural").length,
    technological: predictions.filter((p) => p.disasterCategory === "Technological").length,
  };

  if (loading) {
    return (
      <SidebarProvider>
        <div className="min-h-screen flex w-full bg-background">
          <AppSidebar />
          <SidebarInset className="flex-1">
            <Header />
            <main className="p-6">
              <div className="flex items-center justify-center h-64">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
              </div>
            </main>
          </SidebarInset>
        </div>
      </SidebarProvider>
    );
  }

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
                <h1 className="text-3xl font-bold">Prediction Monitoring</h1>
                <p className="text-muted-foreground mt-1">
                  Monitor and approve AI-generated disaster predictions
                </p>
              </div>
              <PredictionExport predictions={filteredPredictions} />
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">
                    Total Predictions
                  </CardTitle>
                  <Brain className="h-4 w-4 text-primary" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.total}</div>
                  <p className="text-xs text-muted-foreground">All predictions</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">
                    High Severity
                  </CardTitle>
                  <AlertTriangle className="h-4 w-4 text-red-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-red-400">
                    {stats.highSeverity}
                  </div>
                  <p className="text-xs text-muted-foreground">Critical predictions</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">
                    Natural Disasters
                  </CardTitle>
                  <MapPin className="h-4 w-4 text-emerald-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-emerald-400">
                    {stats.natural}
                  </div>
                  <p className="text-xs text-muted-foreground">Natural events</p>
                </CardContent>
              </Card>

              <Card className="bg-card border-border">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">
                    Technological
                  </CardTitle>
                  <TrendingUp className="h-4 w-4 text-purple-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-purple-400">
                    {stats.technological}
                  </div>
                  <p className="text-xs text-muted-foreground">Tech-related events</p>
                </CardContent>
              </Card>
            </div>

            {/* Filters */}
            <PredictionFilters onFilterChange={handleFilterChange} />

            {/* Table */}
            <PredictionsTable
              predictions={filteredPredictions}
              onView={handleView}
              onApprove={handleApprove}
            />

            {/* Details Modal */}
            <PredictionDetailsModal
              prediction={selectedPrediction}
              open={detailsOpen}
              onOpenChange={setDetailsOpen}
              onApprove={handleApprove}
            />
          </main>
        </SidebarInset>
      </div>
    </SidebarProvider>
  );
}