import 'package:begzar/common/utils.dart';
import 'package:begzar/model/plan_model.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/screens/auth_user_screen.dart';
import 'package:begzar/screens/payment_screen.dart';
import 'package:begzar/widgets/code_inputer.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/subscribtion_model.dart';
import 'home_screen.dart';

class SubscribtionScreen extends StatefulWidget {
  SubscribtionScreen({super.key});

  @override
  State<SubscribtionScreen> createState() => _SubscribtionScreenState();
}

class _SubscribtionScreenState extends State<SubscribtionScreen> {
  final PageController controller = PageController(
    initialPage: 0,
    keepPage: true,
  );

  PlanModel? planModelSelected;

  int onItemClicked = 0;
  changeItemIndex(int index) {
    setState(() {
      onItemClicked = index;
    });
  }

  List<PlanModel> subscribtionPlans = [];

  @override
  void initState() {
    super.initState();
    _loadSubscribtion();
  }

  @override
  Widget build(BuildContext context) {
    _check_userSub(context);
    List feature = [
      {
        "title": context.tr('premium_feature_1_title'),
        "description": context.tr('premium_feature_1_description'),
        "icon": "Breaking barriers-rafiki.png"
      },
      {
        "title": context.tr('premium_feature_2_title'),
        "description": context.tr('premium_feature_2_description'),
        "icon": "data-rafiki.png"
      },
      {
        "title": context.tr('premium_feature_3_title'),
        "description": context.tr('premium_feature_3_description'),
        "icon": "Online world-bro.png"
      },
      {
        "title": context.tr('premium_feature_4_title'),
        "description": context.tr('premium_feature_4_description'),
        "icon": "Outer space-rafiki.png"
      },
    ];
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 30,
                        color: Theme.of(context).colorScheme.onSurface,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Spacer(),
                      Text(
                        context.tr('upgrade_to_premium'),
                        style: const TextStyle(
                          fontFamily: 'sb',
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(
                        flex: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Stack(
                      children: [
                        PageView(
                          controller: controller,
                          children: [
                            ...feature.map((item) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (item['icon'] != null)
                                    Image.asset(
                                      'assets/images/premium/${item['icon']}',
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                    ),
                                  if (item['title'] != null)
                                    Text(
                                      item['title'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'sb',
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                      // style: const TextStyle(
                                      //   fontFamily: 'sb',
                                      //   fontSize: 20,
                                      // ),
                                    ),
                                  if (item['description'] != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 60),
                                      child: Text(
                                        item['description'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                        // style: const TextStyle(
                                        //   fontFamily: 'r',
                                        //   fontSize: 16,
                                        // ),
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          width: MediaQuery.of(context).size.width,
                          // right: 16,
                          child: Center(
                            child: SmoothPageIndicator(
                                controller: controller, // PageController
                                count: feature.length,
                                effect: WormEffect(), // your preferred effect
                                onDotClicked: (index) {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (subscribtionPlans.isEmpty)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ...subscribtionPlans
                      .map((e) => InkWell(
                            onTap: () {
                              changeItemIndex(0);
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white10.withAlpha(10),
                                border: onItemClicked == 0
                                    ? Border.all(
                                        color: Colors.blue,
                                        width: 1,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: 80,
                              // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      Text(context.tr(e.planName),
                                          style: TextStyle(
                                            fontFamily: 'sb',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          )),
                                      const Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        // width: 60,
                                        // height: 30,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Center(
                                          child: Text(
                                            context.tr('sugesstion'),
                                            style: TextStyle(
                                              fontFamily: 'sb',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      Text(
                                        '${e.real_price.toString()} تومان',
                                        style: TextStyle(
                                          fontFamily: 'sb',
                                          fontSize: 16,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${context.tr('now_price')}: ${e.discount_price.toString()} تومان',
                                        style: TextStyle(
                                          fontFamily: 'sb',
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 20),
                  const SizedBox(height: 200),
                ],
              ),
            ),

            // const Spacer(),

            // const Spacer(),
            Positioned(
              bottom: 0,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // go to auth screen
                      _checkAndlogin().then((isLoggedIn) async {
                        if (!isLoggedIn) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AuthUserScreen(),
                            ),
                          );

                          _check_userSub(context);
                          return;
                        }

                        // going to payment screen

                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(context.tr('comming_soon')),
                        //     duration: const Duration(seconds: 2),
                        //   ),
                        // );
                        if (subscribtionPlans.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('no_plans_available')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        // go to route PaymentScreen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              planModelSelected:
                                  subscribtionPlans[onItemClicked],
                            ),
                          ),
                        );
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 55,
                      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Center(
                          child: Text(
                        context.tr('continue'),
                        style: const TextStyle(
                          fontFamily: 'sb',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          // color: Colors.white,
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Divider(
                    color: Colors.grey[100]?.withAlpha(20),
                    thickness: 1,
                    indent: MediaQuery.of(context).size.width * 0.1,
                    endIndent: MediaQuery.of(context).size.width * 0.1,
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      // Check if user is logged in

                      // Show the code input dialog
                      showDialog(
                        context: context,
                        builder: (context) => CodeInputerDialog(),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 55,
                      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('login_by_code'),
                            style: const TextStyle(
                              fontFamily: 'sb',
                              fontSize: 16,
                              // color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Iconsax.sms,
                            color: Colors.blue,
                            size: 25,
                          ),
                        ],
                      )),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  _loadSubscribtion() async {
    Dio dio = Dio();

    final res =
        await dio.get('${Utils.base_url}/818_vpn/v1/subscription/plans.php');

    if (res.statusCode == 200) {
      // if (res.data['status'] == 'success') {
      // Handle success response
      // print('Subscription plans loaded successfully');
      print('Subscription plans: ${res.data}');
      // (res.data['plans']);
      setState(() {
        subscribtionPlans = (res.data['plans'] as List)
            .map((plan) => PlanModel.fromJson(plan))
            .toList();
      });
      // You can update your UI or state here with the subscription plans
      // } else {
      // Handle error response
      // print('Error loading subscription plans: ${res.data['message']}');
      // }
    } else {
      // Handle HTTP error
      print('HTTP error: ${res.statusCode}');
    }
  }

  _check_userSub(BuildContext context) async {
    // https://818.arianadevs.com/818_vpn/v1/payment/check_user_sub.php?uid=5CfQJyGiQ0WdMg7h70I3syzK0Zp2
    Dio dio = Dio();

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       context.tr('checking_subscription'),
    //     ),
    //   ),
    // );
    final box = await Hive.openBox<UserInfo>('users');
    UserInfo? userInfo = box.get('users');
    print(userInfo?.uuid);
    if (userInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('please_login_first'),
          ),
        ),
      );

      return;
    }
    // print(userInfo?);
    var res = await dio.get(
      '${Utils.base_url}/818_vpn/v1/payment/check_user_sub.php?uid=${userInfo?.uuid}',
    );

    if (res.statusCode == 200) {
      UserInfo userInfo = UserInfo.fromJson(res.data);

      if (res.data['subscribtion'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('no_active_subscription'),
            ),
          ),
        );
        // Utils.showError(
        //   context,
        //   'اشتراک فعالی وجود ندارد',
        // );

        return;
      }
      SubscribtionModel subscribtionModel =
          SubscribtionModel.fromJson(res.data['subscribtion']);

      final box = await Hive.openBox<UserInfo>('users');
      await box.put('users', userInfo);

      final subBox = await Hive.openBox<SubscribtionModel>('subscribtion');
      await subBox.put('subscribtion', subscribtionModel);

      // نمایش پیام موفقیت
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('code_success_submit'))),
      );

      // بستن دیالوگ
      // Close all page and go to home page
      // Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('error_checking_subscription'),
          ),
        ),
      );
      // Utils.showError(
      //   context,
      //   'خطا در بررسی اشتراک',
      // );
    }
  }
}
