import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:general_pos/constants.dart';
import 'package:general_pos/onboarded.dart';
import 'package:general_pos/screens/main_page.dart';
import 'package:general_pos/screens/onboarding/onboarding_screen.dart';
import 'package:general_pos/theme.dart';
import 'package:general_pos/utilities/providers/cart_item_counter.dart';
import 'package:general_pos/utilities/providers/theme.dart';
import 'package:general_pos/utilities/providers/total_amount.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  try {
    await Hive.openBox('store');
  } catch (error) {
    if (kDebugMode) {
      print('Error opening Hive boxes: $error');
    }
  }

  // Load onboarded status and theme data before running the app
  bool? isOnboarded = await Onboarded.getOnboardedStatus() ?? false;
  ThemeData themeData = await AppTheme.getThemeData();

  runApp(GeneralPOS(
    isOnboarded: isOnboarded,
    themeData: themeData,
  ));
}

class GeneralPOS extends StatelessWidget {
  final bool isOnboarded;
  final ThemeData themeData;

  const GeneralPOS({
    super.key,
    required this.isOnboarded,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    Box<dynamic> store = Hive.box('store');
    clearApp();

    // Initialize Hive boxes if they don't already exist
    if (!store.containsKey('items')) {
      store.put('items', []);
    }

    if (!store.containsKey('cart')) {
      store.put('cart', []);
    }

    if (!store.containsKey('history')) {
      store.put('history', []);
    }

    // Choose the initial page based on onboarding status
    Widget initialPage = isOnboarded ? const MainPage() : const OnboardingScreen();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(themeData)),
        ChangeNotifierProvider(create: (context) => CartItemCounter()),
        ChangeNotifierProvider(create: (context) => TotalAmount()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            theme: themeProvider.themeData,
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            home: initialPage, // Use the initialPage based on onboarding status
          );
        },
      ),
    );
  }
}
