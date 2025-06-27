import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:begzar/ad_manager.dart';
import 'package:begzar/common/cha.dart';
import 'package:begzar/common/encdec.dart';
import 'package:begzar/common/utils.dart';
import 'package:begzar/model/server_model.dart';
import 'package:begzar/model/subscribtion_model.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/screens/subscribtion_screen.dart';
import 'package:begzar/widgets/connection_widget.dart';
import 'package:begzar/widgets/server_selection_modal_widget.dart';
import 'package:begzar/widgets/vpn_status.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/theme.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());
  late final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      v2rayStatus.value = status;
    },
  );

  AdManager adManager = AdManager();

  bool proxyOnly = false;
  List<String> bypassSubnets = [];
  String? coreVersion;
  String? versionName;
  bool isLoading = false;
  int? connectedServerDelay;
  late SharedPreferences _prefs;
  ServerModel selectedServer = ServerModel.empty();
  String? selectedServerLogo;
  String? domainName;
  bool isFetchingPing = false;
  List<String> blockedApps = [];
  List<ServerModel> allservers = [];

  UserInfo? userInfo;
  SubscribtionModel? subscribtionModel = SubscribtionModel.empty();

  Future<bool> _checkAndsSub() async {
    var box = await Hive.openBox<SubscribtionModel>('subscribtion');
    print('Box length: ${box.length}');
    if (box.isNotEmpty) {
      SubscribtionModel? user = box.getAt(0);
      // print('User data: ${user?.uuid}');
      if (user != null) {
        // Perform login with user data

        return true;
      }
    }

    return false;
  }

  bool showUpgrade = false;
  getUserForFirstTime() async {
    Map<String, dynamic>? ipInfo = await Utils.getPublicIPInfo();
    String countryCode = ipInfo?['countryCode'];
    print(ipInfo);
    // print(await _checkAndsSub());
    if (countryCode == "IR" && await _checkAndsSub() == false) {
      setState(() {
        showUpgrade = true;
      });
    }
    // await _checkAndsSub();
  }

  @override
  void initState() {
    _loadUserData();
    super.initState();
    getUserForFirstTime();
    getVersionName();
    _loadServerSelection();
    flutterV2ray
        .initializeV2Ray(
      notificationIconResourceType: "mipmap",
      notificationIconResourceName: "notif_launcher",
    )
        .then((value) async {
      coreVersion = await flutterV2ray.getCoreVersion();

      setState(() {});
      Future.delayed(
        Duration(seconds: 1),
        () {
          if (v2rayStatus.value.state == 'CONNECTED') {
            delay();
          }
        },
      );
    });
  }

  _loadUserData() async {
    final box = await Hive.openBox<UserInfo>('users');
    userInfo = box.get('users');

    final box2 = await Hive.openBox<SubscribtionModel>('subscribtion');
    subscribtionModel =
        box2.get('subscribtion', defaultValue: SubscribtionModel.empty());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isWideScreen = size.width > 600;

    //     final box = await Hive.openBox<UserInfo>('users');
    // await box.put('users', user);

    return Scaffold(
      appBar: isWideScreen ? null : _buildAppBar(isWideScreen),
      backgroundColor: const Color(0xff192028),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showServerSelectionModal(context),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Lottie.asset(
                      selectedServerLogo ?? 'assets/lottie/auto.json',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedServer.location,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        fontFamily: 'GM',
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: v2rayStatus,
                  builder: (context, value, child) {
                    final size = MediaQuery.sizeOf(context);
                    final bool isWideScreen = size.width > 600;
                    return isWideScreen
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ConnectionWidget(
                                          onTap: () =>
                                              _handleConnectionTap(value),
                                          isLoading: isLoading,
                                          status: value.state,
                                        ),
                                        if (value.state == 'CONNECTED') ...[
                                          const SizedBox(height: 16),
                                          _buildDelayIndicator(),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (value.state == 'CONNECTED') ...[
                                    Expanded(
                                      child: VpnCard(
                                        download: value.download,
                                        upload: value.upload,
                                        downloadSpeed: value.downloadSpeed,
                                        uploadSpeed: value.uploadSpeed,
                                        selectedServer: selectedServer,
                                        selectedServerLogo:
                                            selectedServerLogo ??
                                                'assets/lottie/auto.json',
                                        duration: value.duration,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConnectionWidget(
                                onTap: () => _handleConnectionTap(value),
                                isLoading: isLoading,
                                status: value.state,
                              ),
                              if (value.state == 'CONNECTED') ...[
                                const SizedBox(height: 16),
                                _buildDelayIndicator(),
                                const SizedBox(height: 60),
                                VpnCard(
                                  download: value.download,
                                  upload: value.upload,
                                  downloadSpeed: value.downloadSpeed,
                                  uploadSpeed: value.uploadSpeed,
                                  selectedServer: selectedServer,
                                  selectedServerLogo: selectedServerLogo ??
                                      'assets/lottie/auto.json',
                                  duration: value.duration,
                                ),

                                // const SizedBox(height: 10),
                                // subscripbtionStatus widget
                                if (subscribtionModel?.hasActiveSub())
                                  SubscribtionStatus(
                                    subscribtionModel: subscribtionModel,
                                  ),
                              ] else ...[
                                const SizedBox(height: 100),
                                if (subscribtionModel?.hasActiveSub())
                                  SubscribtionStatus(
                                    subscribtionModel: subscribtionModel,
                                  ),
                              ]
                            ],
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    return AppBar(
      title: Text(
        context.tr('app_title'),
        style: TextStyle(
          color: ThemeColor.foregroundColor,
          fontSize: isWideScreen ? 22 : 18,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/logo_transparent.png',
          color: ThemeColor.foregroundColor,
          height: 50,
        ),
      ),
      actions: [
        const SizedBox(width: 10),
        // if(!subscribtionModel?.hasActiveSub())
        if (showUpgrade)
          InkWell(
            onTap: () {
              if (!subscribtionModel?.hasActiveSub())
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SubscribtionScreen(),
                  ),
                );
            },
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.crown5,
                      color: Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subscribtionModel?.hasActiveSub()
                          ? context.tr('premium_subscription')
                          : context.tr('to_subscription'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 10),
      ],
      automaticallyImplyLeading: !isWideScreen,
      centerTitle: true,
      backgroundColor: ThemeColor.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildDelayIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      width: connectedServerDelay == null ? 50 : 90,
      height: 30,
      child: Center(
        child: connectedServerDelay == null
            ? LoadingAnimationWidget.fallingDot(
                color: const Color.fromARGB(255, 214, 182, 0),
                size: 35,
              )
            : _buildDelayDisplay(),
      ),
    );
  }

  Widget _buildDelayDisplay() {
    return SizedBox(
      height: 50,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: delay,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.wifi, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              connectedServerDelay.toString(),
              style: TextStyle(fontFamily: 'GM'),
            ),
            const SizedBox(width: 4),
            const Text('ms'),
          ],
        ),
      ),
    );
  }

  void _handleConnectionTap(V2RayStatus value) async {
    if (value.state == "DISCONNECTED") {
      getDomain();
      // initKey();
    } else {
      // show a dialog when user want to choose should load a rewarded ad
      adManager.loadRewardedAd();
      // TOOD
      AwesomeDialog(
        context: context,
        // body: Text(context.tr('disable_vpn_description')),

        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: context.tr('disable_vpn_title'),
        desc: context.tr('disable_vpn_description'),
        btnCancelText: context.tr('close'),
        btnOkText: context.tr('disconnect_btn'),
        btnOkColor: Colors.red,
        btnCancelColor: Colors.grey,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          // flutterV2ray.stopV2Ray();
          adManager.showRewardedAd(
            onAdClosed: () {
              flutterV2ray.stopV2Ray();
            },
            onUserEarnedReward: () {
              // Handle the reward
              flutterV2ray.stopV2Ray();
            },
          );
        },
      )..show();
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text(context.tr('load_rewarded_ad')),
      //       content: Text(context.tr('load_rewarded_ad_description')),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: Text(context.tr('cancel')),
      //         ),
      //         TextButton(
      //           onPressed: () {
      //             adManager.showRewardedAd(onAdClosed: () {
      //               Navigator.of(context).pop();
      //               flutterV2ray.stopV2Ray();
      //             }, onUserEarnedReward: () {
      //               // Handle the reward
      //               Navigator.of(context).pop();
      //               flutterV2ray.stopV2Ray();
      //             });
      //           },
      //           child: Text(context.tr('OK')),
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  void _showServerSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return ServerSelectionModal(
          selectedServer: selectedServer,
          allservers: allservers,
          onServerSelected: (server, config) {
            if (v2rayStatus.value.state == "DISCONNECTED") {
              String? logoPath;
              if (server == 'Automatic') {
                logoPath = 'assets/lottie/auto.json';
              } else {
                logoPath = 'assets/lottie/server.json';
              }

              setState(() {
                selectedServer = server;
              });
              _saveServerSelection(server, logoPath);
              Navigator.pop(context);
            } else {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr('error_change_server'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  String getServerParam() {
    if (selectedServer == 'Server 1') {
      return 'server_1';
    } else if (selectedServer == 'Server 2') {
      return 'server_2';
    } else {
      return 'auto';
    }
  }

  Future<void> _loadServerSelection() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedServer = ServerModel.fromJson(jsonDecode(
          _prefs.getString('selectedServers') ??
              jsonEncode(ServerModel.empty().toJson())));
      selectedServerLogo =
          _prefs.getString('selectedServerLogos') ?? 'assets/lottie/auto.json';
    });
  }

  Future<void> _saveServerSelection(ServerModel server, String logoPath) async {
    await _prefs.setString('selectedServers', jsonEncode(server.toJson()));
    await _prefs.setString('selectedServerLogos', logoPath);
    setState(() {
      selectedServer = server;
      selectedServerLogo = logoPath;
    });
  }

  Future<List<String>> getDeviceArchitecture() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.supportedAbis;
  }

  void getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionName = packageInfo.version;
    });
  }

  Future<void> getDomain() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        isLoading = true;
        blockedApps = prefs.getStringList('blockedApps') ?? [];
      });
      // final response = await httpClient.get('remote.txt').timeout(
      //   Duration(seconds: 8),
      //   onTimeout: () {
      //     throw TimeoutException(context.tr('error_timeout'));
      //   },
      // );
      // domainName = response.data;
      checkUpdate();
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message!,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('error_domain')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String decrypt(String secureData, String x1, String x2, String key) {
    final encryptedData = {
      'ciphertext': secureData, // secure
      'nonce': x1, // x1
      'tag': x2 // x2
    };
    final savedKey = key;
    try {
      final decrypted = Decryptor.decryptChaCha20(encryptedData, savedKey);
      return decrypted.toString();
    } catch (e) {
      return 'Error during decryption: $e';
    }
  }

  Future<Response> _newConfigs(UserInfo user) async {
    // var data = FormData.fromMap({'uid': user.uuid, 'token': user.token});

    var dio = Dio();
    var response = await dio.request(
      'https://818.arianadevs.com/818_vpn/v1/payment/check_user_sub.php?uid=${user.uuid}&token=${user.token}',
      options: Options(
        method: 'GET',
      ),
      // data: data,
    );

    // if (response.statusCode == 200) {
    return (response);

    // }
  }

  void checkUpdate() async {
    try {
      final serverParam = getServerParam();

      String userKey = Utils.enc_key;

      if (selectedServer.location != 'Automatic') {
        return connectToSelectedServer();
      }
      // if (userKey == '') {
      //   final response = await Dio()
      //       .get(
      //     "https://raw.githubusercontent.com/abbasnazari-0/818_vpn_source/refs/heads/main/remote.txt",
      //     options: Options(
      //       headers: {
      //         // 'X-Content-Type-Options': 'nosniff',
      //       },
      //     ),
      //   )
      //       .timeout(
      //     Duration(seconds: 8),
      //     onTimeout: () {
      //       throw TimeoutException(context.tr('error_timeout'));
      //     },
      //   );
      //   final dataJson = response.data;
      //   // print(dataJson);
      //   final key = dataJson['key'];
      //   userKey = key;
      //   await storage.write(key: 'user', value: key);
      // } else {
      //   userKey = await storage.read(key: 'user') ?? '';
      // }
      String configs = """    [
  {
        "config": "vless://0a6658f9-6fea-4eee-829d-d40aaa09d573@168.119.48.117:20372?type=ws&path=%2F&host=&security=none#q6d1ggsk",
        "location": "Germany",
        "country_code": "DE",
        "is_premium": true

  
    },
    {
        "config": "vless://7f66d48b-b361-4c5f-8d0a-f51c73f41ae7@135.181.42.145:13840?type=ws&path=%2F&host=&security=none#818_FLASH_VPN-52p3fym8",
        "location": "Finland",
        "country_code": "FI",
        "is_premium": false

  
    }
  ]



""";

      // final String encrypted = EncDec().encryptString(configs);
      // final String decrypted = EncDec().decryptString(
      //     "gAAAAABoTEVoy/qx3DqDApltyWgEeXefKjl/AfadavVY+DZzQic8r6glRGP8Sn2b8K7514NGBk5N5eUCzn1OUKCshI3mJfI8emTmqM+9KWj6fbb6TYwpEJf7kc8/8tVMckJlXWlBlsMFS6kclZZ0lpql/sGMpw7NmvrrM0+uRwrjQ07TU67Fv6CaD3VypBA0um4RlkYzgrS+EZQYqVygPCHBB9ijynTMNT+HePh20sxNCulv583yapOCNfu09JPR6VaZfAV75eSpQejH0ZunadfXdetVRlhQ/7WrkaITVS9n7YVqHeGOZgCOC10ZJf7RYG4SwlwzPgVU0cAZHc4epJhhUAta5vAwNUPxr4d8Sv8DiUJq84kzod8jCH509Tw9+abkzSzG0rtAkogEjgNuudTVTpN3g16rZAJVpo6/YAK80EZQ+RAyNmCwVN4+ocRaTsWl2tY4KHbs7dn4BdHEFDaSMjJ2S2/auc7jw1zmpSdcPN8a7wuULS9AtfsbCLcYPix1jX+Vdw0sHy+tJNTh0Zk8I+0j3HDuvwmG9Hk78dL/WXodxdHcVTOC2HSOJcuLpNpuWPQtajbqo41EK1P/Sp/ha6GHyNZExCvR0+Vw0tRoGpxXvP4By2o3E3TUEAl7JriRpp1JSZ5/rA20fEuUwj9K0BSC6pIPMM0wBLs467/EH1vfwtpdxoThvE8wI/VXJbLZwizlq1dskPWXZDpMSQ8XvPLtjMg6qrhD643gFdkYYTPpilgpNaJCvkHTTSnXv2qnAatFox7U/7vA3oMfNl3UdDpeRz43HrSkQr8ifpJpMXwI0Wquc1cwOPbfFHeWeniBPcuF4cqybYiQyiZ6tl8IaiQAc5c2MTw5mbBYqsZVKaH/rvE4tpl5C3rAHPs7/xbQOShRTXh8gD22e7HjLGaQ5ERzDy6pHb6tPNQ/aEgVfcpGb1LsS7pWbaAegqg+kPpiHY296AIEWzzTO67X/1P3ZwbX81184p2HEqtlGJXquhiN3PMQnzCAJKAQFecmHKBIMjLAhXNdjOfXdMoHS7yYLrx8Y43wEQ==");
      // print('Encryptdecrypteded: $decrypted');
      // return;
      List<ServerModel> servers = [];
      bool isSubscribed = await _checkAndsSub();
      if (!isSubscribed) {
        final response = await Dio()
            .get(
          "https://raw.githubusercontent.com/abbasnazari-0/818_vpn_source/refs/heads/main/remote.txt",
          options: Options(
            headers: {
              'X-Content-Type-Options': 'nosniff',
            },
          ),
        )
            .timeout(
          Duration(seconds: 8),
          onTimeout: () {
            throw TimeoutException(context.tr('error_timeout'));
          },
        );
        final jsonData =
            jsonDecode(EncDec().decryptString(response.data.toString().trim()));
        // print(jsonData);
        // ServerModel serverModel = ServerModel.fromJson(jsonData);

        // if (response.data['status'] == true) {
        // final dataJson = response.data;
        // final secureData = dataJson['data']['secure'];
        // final x1 = dataJson['data']['x1'];
        // final x2 = dataJson['data']['x2'];
        // final version = dataJson['version'];
        // final updateUrl = dataJson['updated_url'];

        // final serverEncode = decrypt(secureData, x1, x2, userKey);

        servers = List<ServerModel>.from(
          jsonData.map((item) => ServerModel.fromJson(item)),
        );
        allservers = servers;
      } else {
        try {
          Response res = await _newConfigs(userInfo!);

          if (res.statusCode == 200) {
            UserInfo userInfo = UserInfo.fromJson(res.data);
            SubscribtionModel subscribtionModel =
                SubscribtionModel.fromJson(res.data['subscribtion']);
            // Handle successful response
            final box = await Hive.openBox<UserInfo>('users');
            await box.put('users', userInfo);

            final subBox =
                await Hive.openBox<SubscribtionModel>('subscribtion');
            await subBox.put('subscribtion', subscribtionModel);

            servers = List<ServerModel>.from(
                res.data['configs'].map((item) => ServerModel(
                      "",
                      "",
                      config: item,
                      location: "",
                      id: 1,
                    )));

            //  ServerModel(
            //       "",
            //       "",
            //       pingTime: -2,
            //       isPremium: true,
            //       config: item['config'],
            //       location: "Premium Server",
            //       id: 1,
            //     )),
            // );
            // servers = servers;
          } else {
            // Handle error response
          }
        } on DioException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${context.tr('error_get_version')} ${e.message}",
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      print('Servers: ${servers.length}');
      if (versionName == versionName) {
        await connect(servers);
      } else {}
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message!,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('error_get_version'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> connect(List<ServerModel> serverList) async {
    if (serverList.isEmpty) {
      // سرور یافت نشد
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('error_no_server_connected'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<String> list = [];

    serverList.forEach((element) {
      final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(element.config);

      list.add(v2rayURL.getFullConfiguration());
    });

    Map<String, dynamic> getAllDelay =
        jsonDecode(await flutterV2ray.getAllServerDelay(configs: list));

    list.clear();

    int minPing = 99999999;
    String bestConfig = '';

    getAllDelay.forEach(
      (key, value) {
        if (value < minPing && value != -1) {
          setState(() {
            bestConfig = key;
            minPing = value;
          });
        }
      },
    );

    if (bestConfig.isNotEmpty) {
      if (await flutterV2ray.requestPermission()) {
        flutterV2ray.startV2Ray(
          remark: context.tr('app_title'),
          config: bestConfig,
          proxyOnly: false,
          bypassSubnets: null,
          notificationDisconnectButtonName: context.tr('disconnect_btn'),
          blockedApps: blockedApps,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('error_permission')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('error_no_server_connected'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    Future.delayed(
      Duration(seconds: 1),
      () {
        delay();
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> connectToSelectedServer() async {
    if (selectedServer.location == 'Automatic') {
      connect(allservers);
      return;
      // سرور یافت نشد
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(
      //         context.tr('error_no_server_connected'),
      //       ),
      //       behavior: SnackBarBehavior.floating,
      //     ),
      //   );
      // }
      // setState(() {
      //   isLoading = false;
      // });
      // return;
    }

    setState(() {
      isLoading = true;
    });

    List<String> list = [];

    // serverList.forEach((element) {
    //   final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(element.config);

    //   list.add(v2rayURL.getFullConfiguration());
    // });

    // Map<String, dynamic> getAllDelay =
    //     jsonDecode(await flutterV2ray.getAllServerDelay(configs: list));

    // list.clear();

    // int minPing = 99999999;
    // String bestConfig = '';

    // getAllDelay.forEach(
    //   (key, value) {
    //     if (value < minPing && value != -1) {
    //       setState(() {
    //         bestConfig = key;
    //         minPing = value;
    //       });
    //     }
    //   },
    // );

    // if (bestConfig.isNotEmpty) {
    if (await flutterV2ray.requestPermission()) {
      flutterV2ray.startV2Ray(
        remark: context.tr('app_title'),
        config: selectedServer.fullConfiguration(),
        proxyOnly: false,
        bypassSubnets: null,
        notificationDisconnectButtonName: context.tr('disconnect_btn'),
        blockedApps: blockedApps,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('error_permission')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    // } else {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           context.tr('error_no_server_connected'),
    //         ),
    //         behavior: SnackBarBehavior.floating,
    //       ),
    //     );
    //   }
    // }
    Future.delayed(
      Duration(seconds: 1),
      () {
        delay();
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  void delay() async {
    if (v2rayStatus.value.state == 'CONNECTED') {
      connectedServerDelay = await flutterV2ray.getConnectedServerDelay();
      setState(() {
        isFetchingPing = true;
      });
    }
    if (!mounted) return;
  }
}

class SubscribtionStatus extends StatelessWidget {
  const SubscribtionStatus({super.key, required this.subscribtionModel});
  final SubscribtionModel? subscribtionModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      // height: 100,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade100.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10),

              Icon(
                Iconsax.crown5,
                size: 30,
                color: Colors.yellowAccent,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //
                  Row(
                    children: [
                      Text("🗓️ اشتراک فعال " +
                          "(${subscribtionModel?.planName.toString()})"),
                      // Spacer(),
                      // Text(
                      //   subscribtionModel?.planName ?? '',
                      //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      // ),
                    ],
                  ),
                  Text("⏳" +
                      "${subscribtionModel?.getRemindedDay().toString()}" +
                      " " +
                      "روز دیگه"),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("📅	" +
                          "${subscribtionModel?.getFormattedRangeFa().toString()}"),
                    ],
                  ),
                ],
              ),

              _buildIpButton()
              // تمدید اشتراک button
            ],
          ),
          LinearProgressIndicator(
            value: subscribtionModel?.getProgress(),
          )
        ],
      ),
    );
  }

  Widget _buildIpButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // setState(() => isLoading = true);
            // final ipInfo = await getIpApi();
            // setState(() {
            //   ipflag = countryCodeToFlagEmoji(ipInfo['countryCode']!);
            //   ipText = ipInfo['ip'];
            //   isLoading = false;
            // });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...[
                  Text(
                    'تمدید اشتراک',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontFamily: 'GM',
                      fontSize: 13,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
