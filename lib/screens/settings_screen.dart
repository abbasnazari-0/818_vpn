import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:begzar/common/theme.dart';
import 'package:begzar/main.dart';
import 'package:begzar/model/subscribtion_model.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/widgets/settings/blocked_apps_widget.dart';
import 'package:begzar/widgets/settings/language_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  SettingsWidget({super.key});

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();

    checkLogin();
  }

  // بارگذاری زبان از SharedPreferences
  void _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  bool isLogined = false;

  checkLogin() async {
    if (await _checkAndlogin()) {
      // User is logged in
      setState(() {
        isLogined = true;
      });

      // User is not logged in
    }
  }

  Future<bool> _checkAndlogin() async {
    var box = await Hive.openBox<UserInfo>('users');
    print('Box length: ${box.length}');
    if (box.isNotEmpty) {
      UserInfo? user = box.getAt(0);
      print('User data: ${user?.uuid}');
      if (user != null) {
        // Perform login with user data

        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('setting'),
          style: TextStyle(color: ThemeColor.foregroundColor, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logo_transparent.png',
              color: ThemeColor.foregroundColor,
              height: 50,
            ),
          ),
        ],
        backgroundColor: ThemeColor.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: ThemeColor.backgroundColor,
      body: SettingsList(
        contentPadding: EdgeInsets.all(20),
        brightness: Brightness.dark,
        darkTheme: SettingsThemeData(
          settingsSectionBackground: Color(0xff192028),
          settingsListBackground: Color(0xff192028),
        ),
        sections: [
          SettingsSection(
            title: Text(
              context.tr('blocking_settings'),
              style: TextStyle(fontFamily: 'sm'),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Text(
                  context.tr('block_application'),
                  style: TextStyle(fontFamily: 'sb'),
                ),
                leading: Icon(Icons.block),
                description: Text(
                  context.tr('block_detail'),
                  style: TextStyle(fontFamily: 'sm', fontSize: 12),
                ),
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlockedAppsWidgets(),
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              context.tr('language_settings'),
              style: TextStyle(fontFamily: 'sm'),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Text(
                  context.tr('language'),
                  style: TextStyle(fontFamily: 'sb'),
                ),
                leading: Icon(Icons.language),
                description: _selectedLanguage != null
                    ? Text(
                        _selectedLanguage!,
                        style: TextStyle(fontFamily: 'sm', fontSize: 12),
                      )
                    : null,
                onPressed: (context) {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => LanguageWidget(
                        selectedLanguage: _selectedLanguage!,
                      ),
                    ),
                  )
                      .then((value) {
                    _loadSelectedLanguage();
                  });
                },
              ),
            ],
          ),
          if (isLogined)
            SettingsSection(
              title: Text(
                context.tr('account'),
                style: TextStyle(fontFamily: 'sm'),
              ),
              tiles: [
                SettingsTile.navigation(
                  title: Text(
                    context.tr('logout'),
                    style: TextStyle(
                        fontFamily: 'sb', color: Colors.red, fontSize: 14),
                  ),
                  leading: Icon(
                    Iconsax.logout,
                    color: Colors.red,
                  ),
                  // description: _selectedLanguage != null
                  //     ? Text(
                  //         _selectedLanguage!,
                  //         style: TextStyle(fontFamily: 'sm', fontSize: 12),
                  //       )
                  //     : null,
                  onPressed: (context) {
                    AwesomeDialog(
                      context: context,
                      // body: Text(context.tr('disable_vpn_description')),

                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: context.tr('logout'),
                      desc: context.tr('logout_desc'),
                      btnCancelText: context.tr('close'),
                      btnOkText: context.tr('logout'),
                      btnOkColor: Colors.red,
                      btnCancelColor: Colors.grey,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        // flutterV2ray.stopV2Ray();
                        _logoutUser();
                      },
                    )..show();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  _logoutUser() async {
    final box = await Hive.openBox<UserInfo>('users');
    box.clear();

    final box2 = await Hive.openBox<SubscribtionModel>('subscribtion');
    box2.clear();
    setState(() {});

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => RootScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
