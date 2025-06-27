import 'package:begzar/common/theme.dart';
import 'package:begzar/model/subscribtion_model.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/screens/about_screen.dart';
import 'package:begzar/screens/home_screen.dart';
import 'package:begzar/screens/settings_screen.dart';
import 'package:begzar/widgets/navigation_rail_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/model/v2ray_status.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_device/safe_device.dart';

import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // MobileAds.instance.initialize();
  await NotificationService().initialize();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Initialize Hive

  await Hive.initFlutter();

// Register adapter for User class
  Hive.registerAdapter<UserInfo>(UserInfoAdapter());
  Hive.registerAdapter<SubscribtionModel>(SubscribtionModelAdapter());
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  //
  // if (kDebugMode) {
  //   FirebaseCrashlytics.instance
  //       .setCrashlyticsCollectionEnabled5(true); //disable false
  // } else {
  //   FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // }

  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: [
        'D79B1AC1C7E2CC1A9ED38C9C9C4BCDBF'
      ], // Replace with your test device ID
    ),
  );
  bool isJailBroken = await SafeDevice.isJailBroken;
  if (isJailBroken != true) {
    await EasyLocalization.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: ThemeColor.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    // Dio dio =
    runApp(
      EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('fa', 'IR'),
          Locale('zh', 'CN'),
          Locale('ru', 'RU'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        startLocale: Locale('en', 'US'),
        saveLocale: true,
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =
        TextStyle(fontFamily: 'sm', color: Color(0xffF7FAFF));
    return MaterialApp(
      title: '818 Flash VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          titleLarge: defaultTextStyle,
          titleMedium: defaultTextStyle,
          titleSmall: defaultTextStyle,
          bodyLarge: defaultTextStyle,
          bodyMedium: defaultTextStyle,
          bodySmall: defaultTextStyle,
          labelLarge: defaultTextStyle,
          labelMedium: defaultTextStyle,
          labelSmall: defaultTextStyle,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: ThemeColor.backgroundColor,
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 1;
  final v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [SettingsWidget(), HomePage(), AboutScreen()];
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          AnimatedSlide(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: isWideScreen ? Offset.zero : Offset(1, 0),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isWideScreen ? 1 : 0,
              child: isWideScreen
                  ? NavigationRailWidget(
                      selectedIndex: _selectedIndex,
                      singStatus: v2rayStatus,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                    )
                  : SizedBox(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? Container(
              decoration: BoxDecoration(
                color: Color(0xff192028),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBar(
                backgroundColor: Color(0xff192028),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(Iconsax.setting, color: Colors.grey),
                    selectedIcon: Icon(Iconsax.setting, color: Colors.white),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.home, color: Colors.grey),
                    selectedIcon: Icon(Iconsax.home, color: Colors.white),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.info_circle, color: Colors.grey),
                    selectedIcon:
                        Icon(Iconsax.info_circle, color: Colors.white),
                    label: '',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
