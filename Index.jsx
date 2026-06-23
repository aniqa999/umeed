import React, { useEffect, useState } from "react";
import { AlertTriangle, Activity, Clock, Users } from "lucide-react";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { KPICard } from "../components/dashboard/KPICard";
import { PredictionChart } from "../components/dashboard/PredictionChart";
import { ResourceChart } from "../components/dashboard/ResourceChart";
import { SystemHealthPanel } from "../components/dashboard/SystemHealthPanel";
import { RecentActionsLog } from "../components/dashboard/RecentActionsLog";
import { DisasterMap } from "../components/dashboard/DisasterMap";
import { useAuth } from "../context/AuthContext";
import { getStats } from "../lib/api";

const Index = () => {
  const { token } = useAuth();
  const [stats, setStats] = useState(null);
  const [loadingStats, setLoadingStats] = useState(true);

  useEffect(() => {
    if (!token) return;
    setLoadingStats(true);
    getStats(token)
      .then((data) => setStats(data.stats ?? null))
      .catch(() => setStats(null))
      .finally(() => setLoadingStats(false));
  }, [token]);

  const totalDisasters = stats?.disasters?.total ?? "—";
  const pendingUsers   = stats?.users?.pending ?? "—";
  const totalUsers     = stats?.users?.total ?? "—";
  const activityLast7  = stats?.activity?.last7Days ?? "—";

  return (
    <div className="flex min-h-screen w-full bg-background">
      <AppSidebar />

      <div className="flex-1 flex flex-col">
        <Header />

        <main className="flex-1 p-6 overflow-auto">
          {/* Page Title */}
          <div className="mb-8">
            <h1 className="text-2xl font-bold text-foreground">Dashboard</h1>
            <p className="text-muted-foreground">Real-time disaster monitoring and system overview</p>
          </div>

          {/* KPI Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <KPICard
              title="Total Disasters"
              value={loadingStats ? "…" : String(totalDisasters)}
              change="All recorded events"
              changeType="neutral"
              icon={AlertTriangle}
              variant="critical"
            />
            <KPICard
              title="Activity (7 days)"
              value={loadingStats ? "…" : String(activityLast7)}
              change="Recent system actions"
              changeType="increase"
              icon={Activity}
              variant="info"
            />
            <KPICard
              title="Pending Approvals"
              value={loadingStats ? "…" : String(pendingUsers)}
              change="Users awaiting review"
              changeType="neutral"
              icon={Clock}
              variant="warning"
            />
            <KPICard
              title="Total Users"
              value={loadingStats ? "…" : String(totalUsers)}
              change="NGOs & government"
              changeType="neutral"
              icon={Users}
              variant="default"
            />
          </div>

          {/* Charts Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <PredictionChart />
            <DisasterMap />
          </div>

          {/* Bottom Row */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <ResourceChart />
            <SystemHealthPanel />
            <RecentActionsLog />
          </div>
        </main>
      </div>
    </div>
  );
};

export default Index;
