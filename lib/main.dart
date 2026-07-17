import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme/app_theme.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';
import 'services/ad_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await ProgressService.instance.init();
  await AudioService.instance.init();

  // Child-directed treatment - same policy as the rest of the series.
  final requestConfig = RequestConfiguration(
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
    maxAdContentRating: MaxAdContentRating.g,
  );
  MobileAds.instance.updateRequestConfiguration(requestConfig);
  await MobileAds.instance.initialize();
  AdService.instance.preloadInterstitial();

  runApp(const AshkaliApp());
}

class AshkaliApp extends StatelessWidget {
  const AshkaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أشكالي',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      builder: (context, child) {
        // Force RTL for the whole app - Arabic-first, same as the series.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
