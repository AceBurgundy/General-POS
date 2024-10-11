import 'package:general_pos/app_name.dart';
import 'package:general_pos/onboarded.dart';
import 'package:general_pos/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:general_pos/utilities/string_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/dot_indicators.dart';
import 'components/onboard_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  bool isButtonEnabled = false;

  final TextEditingController _appNameController = TextEditingController(text: Texts.appName);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _appNameController.addListener(() =>
      setState(() => isButtonEnabled = _appNameController.text.isNotEmpty)
    );

    // Delay the focus request to ensure the TextField is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {

    Expanded imageIllustrationSlider = Expanded(
      flex: 14,
      child: PageView.builder(
        itemCount: onboardingData.length,
        onPageChanged: (value) => setState(() => currentPage = value),
        itemBuilder: (context, index) => OnboardContent(
          illustration: onboardingData[index]["illustration"],
          title: onboardingData[index]["title"],
          text: onboardingData[index]["text"],
        ),
      ),
    );

    Row pageIndicator = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
            (index) => DotIndicator(isActive: index == currentPage),
      ),
    );

    Padding appNameInput = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        textAlign: TextAlign.center,
        focusNode: _focusNode,
        controller: _appNameController,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );

    Padding continueButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: !isButtonEnabled
            ? null
            : () async {
                AppName.set(_appNameController.text);
                Onboarded.setOnboardedStatus(true);

                if (mounted) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const MainPage()
                  ));
                }
              },
            child: const Text(Texts.letsGo),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            imageIllustrationSlider,
            const Spacer(),
            pageIndicator,
            const Spacer(flex: 1),
            appNameInput,
            const Spacer(flex: 1),
            continueButton,
            const Spacer()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// Demo data for our POS System Onboarding screen
List<Map<String, dynamic>> onboardingData = [
  {
    "illustration": "assets/illustrations/inventory.svg",
    "title": "Add Products to your Inventory",
    "text":
    "Easily add new products to your inventory\nwith just a few taps.",
  },
  {
    "illustration": "assets/illustrations/payments.svg",
    "title": "Streamlined Cashiering",
    "text":
    "Quick and efficient checkout process\nfor a seamless customer experience.",
  },
  {
    "illustration": "assets/illustrations/ui.svg",
    "title": "Intuitive User Interface",
    "text":
    "A clean and easy-to-use interface\nthat makes managing your store simple.",
  },
];
