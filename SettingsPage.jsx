import React from "react";
import { SidebarProvider, SidebarInset } from "../components/ui/sidebar";
import { AppSidebar } from "../components/layout/AppSidebar";
import { Header } from "../components/layout/Header";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { RolePermissionMatrix } from "../components/settings/RolePermissionMatrix";
import { ThemeSettings } from "../components/settings/ThemeSettings";
import { ComplianceStatus } from "../components/settings/ComplianceStatus";
import { Settings, Scale, Palette } from "lucide-react";

const SettingsPage = () => {
  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full bg-background">
        <AppSidebar />
        <SidebarInset className="flex-1">
          <Header />
          <main className="flex-1 p-6">
            <div className="max-w-7xl mx-auto space-y-6">
              {/* Page Header */}
              <div>
                <h1 className="text-3xl font-bold flex items-center gap-3">
                  <Settings className="h-8 w-8 text-primary" />
                  System Settings
                </h1>
                <p className="text-muted-foreground mt-1">
                  Configure system-wide policies, security settings, and compliance monitoring
                </p>
              </div>

              {/* Tabs Navigation */}
              <Tabs defaultValue="roles" className="space-y-6">
                <TabsList className="grid w-full grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 h-auto gap-2 bg-transparent p-0">                  
                  <TabsTrigger
                    value="roles"
                    className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground flex items-center gap-2"
                  >
                    <Settings className="h-4 w-4" />
                    <span className="hidden sm:inline">Roles</span>
                  </TabsTrigger>
                  <TabsTrigger
                    value="theme"
                    className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground flex items-center gap-2"
                  >
                    <Palette className="h-4 w-4" />
                    <span className="hidden sm:inline">Theme</span>
                  </TabsTrigger>
                  <TabsTrigger
                    value="compliance"
                    className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground flex items-center gap-2"
                  >
                    <Scale className="h-4 w-4" />
                    <span className="hidden sm:inline">Compliance</span>
                  </TabsTrigger>
                </TabsList>                

                <TabsContent value="roles" className="mt-6">
                  <RolePermissionMatrix />
                </TabsContent>

                <TabsContent value="theme" className="mt-6">
                  <ThemeSettings />
                </TabsContent>

                <TabsContent value="compliance" className="mt-6">
                  <ComplianceStatus />
                </TabsContent>
              </Tabs>
            </div>
          </main>
        </SidebarInset>
      </div>
    </SidebarProvider>
  );
};

export default SettingsPage;