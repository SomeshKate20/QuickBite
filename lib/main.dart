import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/auth_provider.dart';
import 'package:quickbite/providers/cart_provider.dart';
import 'package:quickbite/providers/menu_provider.dart';
import 'package:quickbite/providers/order_provider.dart';
import 'package:quickbite/screens/auth_screen.dart';
import 'package:quickbite/screens/cart_screen.dart';
import 'package:quickbite/screens/home_screen.dart';
import 'package:quickbite/screens/order_confirmation_screen.dart';
import 'package:quickbite/screens/order_status_screen.dart';
import 'package:quickbite/screens/profile_screen.dart';
import 'package:quickbite/screens/splash_screen.dart';
import 'package:quickbite/services/notification_service.dart';
import 'package:quickbite/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // For development, continue without Firebase
  }
  runApp(const QuickBiteApp());
}

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QuickBite',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
          useMaterial3: true,
          scaffoldBackgroundColor: kBackgroundColor,
          appBarTheme: const AppBarTheme(backgroundColor: kPrimaryColor),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.auth: (_) => const AuthScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.cart: (_) => const CartScreen(),
          AppRoutes.orderConfirmation: (_) => const OrderConfirmationScreen(),
          AppRoutes.orderStatus: (_) => const OrderStatusScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
