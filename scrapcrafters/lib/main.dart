import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scrap_provider.dart';
import 'providers/product_provider.dart';
import 'providers/industry_provider.dart';
import 'providers/coin_provider.dart';
import 'screens/landing/landing_page.dart';
import 'screens/user/user_dashboard.dart';
import 'screens/partner/dealer_dashboard.dart';
import 'screens/partner/artist_dashboard.dart';
import 'screens/industry/industry_dashboard.dart';
import 'widgets/loading_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ScrapCraftersApp());
}

class ScrapCraftersApp extends StatelessWidget {
  const ScrapCraftersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScrapProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => IndustryProvider()),
        ChangeNotifierProvider(create: (_) => CoinProvider()),
      ],
      child: MaterialApp(
        title: 'ScrapCrafters',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: LoadingOverlay(message: 'Starting up...'),
          );
        }

        if (auth.isLoggedIn) {
          switch (auth.userRole) {
            case 'dealer':
              return const DealerDashboard();
            case 'artist':
              return const ArtistDashboard();
            case 'industry':
              return const IndustryDashboard();
            default:
              return const UserDashboard();
          }
        }

        return const LandingPage();
      },
    );
  }
}
