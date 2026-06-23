import 'package:flutter/material.dart';
import 'package:umeed_v0/screens/reports/impact_reports.dart';
import 'package:umeed_v0/screens/reports/recovery_resources.dart';
import 'package:umeed_v0/screens/profile/user_details.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/impact/impact_prediction_page.dart';
import 'screens/ngo/ngo_page.dart';
import 'screens/population/population_demo.dart';
import 'screens/reports/disaster_reports.dart';
import 'screens/resources/resource_calc.dart';
import 'screens/splashScreen.dart';
import 'screens/auth/login.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/pending_approval.dart';
import 'screens/profile/profile.dart';
import 'screens/weather/weather_page.dart';
import 'package:umeed_v0/screens/impact/non_disaster_impact.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMEED Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7A1C1C)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // Auth Routes
        '/': (context) => const SplashScreen(), // Required
        '/login': (context) => const LoginPage(), // Required
        '/signup': (context) => const SignupPage(), // Required
        '/pending-approval': (context) => const PendingApprovalPage(), // Required

        // Tab screens (footer tabs 1–6)
        // Tab 1 – Dashboard
        '/dashboard': (context) => const DashboardPage(), // Required // Required
        // Tab 2 – Weather
        '/weather': (context) => const WeatherForecastPage(), // Required
        // Tab 3 – Predict
        '/predict': (context) => const ImpactPredictionPage(), // Required // Required
        // Tab 4 – Resource calculator
        '/resource-calculation': (context) => const ResourceCalculationPage(), // Required // Required
        // Tab 5 – Reports
        '/reports': (context) => const DisasterReportsHub(), // Required //Required
        // Tab 6 – Profile
        '/profile': (context) => const ProfilePage(), // Required // Required


        // Dashboard Menu Routes
        // NGOs (push screen, back button returns to previous tab screen)
        '/ngo': (context) => const NgoPage(), // Required // Required 
        // Population (push screen, back button returns to previous tab screen)
        '/population': (context) => const PopulationDemoGraphics(), // Required // Required
        
        // Disaster Selector Model Route
        '/predict-tech': (context) => const TechImpactPredictionPage(), // Required // Required

        // Push-only sub-screens (always have back button, no footer nav)
        // Impact Reports Only
        '/impact-reports': (context) => const ImpactReportsScreen(), // Required // Required
        // Resource Reports Only
        '/recovery-resources': (context) => const RecoveryResourcesScreen(), // Required // Required
        // Profile Screen Only
        '/me': (context) => const UserDetailPage(), // Required
      },
    );
  }
}
