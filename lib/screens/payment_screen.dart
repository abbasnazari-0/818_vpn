import 'dart:io';

import 'package:begzar/common/page_status.dart';
import 'package:begzar/model/plan_model.dart';
import 'package:begzar/model/subscribtion_model.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/screens/home_screen.dart';
import 'package:begzar/screens/receipt_waiting_room.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:begzar/common/utils.dart';
import 'package:begzar/model/payment_method.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension;
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.planModelSelected});
  final PlanModel? planModelSelected;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<PaymentType> paymentMethods = [];

  @override
  void initState() {
    _loadPaymentMethod();
    super.initState();
  }

  int choosedItem = 0;
  changeChossedItem(int index) {
    setState(() {
      choosedItem = index;
    });
  }

  PageStatus receiptStatus = PageStatus.initial;
  String receiptText = "آپلود رسید";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  context.tr('payment_screen'),
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
            // Center(
            //   child: RiveAnimation.asset(
            //     'assets/lottie/login_screen_character.riv',
            //   ),
            // )

            const SizedBox(height: 20),
            Center(
              child: Text(
                'مبلغ قابل پرداخت',
                style: const TextStyle(
                  fontFamily: 'sb',
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${Utils.seRagham(widget.planModelSelected?.discount_price.toStringAsFixed(0) ?? '')} تومان',
                style: const TextStyle(
                  fontFamily: 'sb',
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                  // shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        //  create border radius
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white10,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Column(
                        children: [
                          if (paymentMethods[index].type == "card")
                            InkWell(
                              onTap: () => changeChossedItem(1),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Radio(
                                        value: 1,
                                        onChanged: (v) {
                                          changeChossedItem(1);
                                        },
                                        groupValue: choosedItem,
                                      ),
                                      Spacer(),
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(
                                          '${_number4Digits(paymentMethods[index].cardNumber.toString())}',
                                          style: const TextStyle(
                                            fontFamily: 'sb',
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Utils.showError(
                                          //   context,
                                          //   'این قسمت در حال حاضر غیرفعال است',
                                          // );
                                        },
                                        icon: Icon(
                                          Iconsax.copy,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          paymentMethods[index].name.toString(),
                                          style: const TextStyle(
                                            fontFamily: 'sb',
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${paymentMethods[index].bankName.toString()}',
                                          style: const TextStyle(
                                            fontFamily: 'sb',
                                            fontSize: 14,
                                          ),
                                        ),
                                        // icon copy
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(
                                    color: Colors.white30,
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 10),
                                  InkWell(
                                    onTap: () {
                                      _chooseReciptPhotoFromGallery();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            receiptText,
                                            style: const TextStyle(
                                              fontFamily: 'sb',
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            child: Icon(
                                              (receiptStatus ==
                                                      PageStatus.initial)
                                                  ? Iconsax.arrow_left_2
                                                  : (receiptStatus ==
                                                          PageStatus.loaded)
                                                      ? Iconsax.tick_square4
                                                      : Iconsax.eraser,
                                              color: Colors.white,
                                            ),
                                            onTap: () {
                                              // Utils.showError(
                                              //   context,
                                              //   'این قسمت در حال حاضر غیرفعال است',
                                              // );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (paymentMethods[index].type == "online")
                            InkWell(
                              onTap: () {
                                changeChossedItem(2);
                                // Utils.showError(
                                //   context,
                                //   'این قسمت در حال حاضر غیرفعال است',
                                // );
                              },
                              child: Column(children: [
                                Row(children: [
                                  Radio(
                                    value: 2,
                                    onChanged: (v) {
                                      changeChossedItem(2);
                                    },
                                    groupValue: choosedItem,
                                  ),
                                  // const Spacer(),
                                  Text(
                                    'پرداخت آنلاین',
                                    style: const TextStyle(
                                      fontFamily: 'sb',
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'با درگاه های پرداخت',
                                    style: const TextStyle(
                                      // fontFamily: 'sb',
                                      fontSize: 12,
                                    ),
                                  ),
                                  // icon
                                  const Spacer(),
                                  Icon(
                                    Iconsax.arrow_left_2,
                                    color: Colors.white,
                                    // size: 20,
                                  ),
                                  const SizedBox(width: 20),
                                ])
                              ]),
                            ),
                          // Spacer(),
                        ],
                      ),
                    );
                  }),
            ),

            // Spacer(),
            if (choosedItem == 2)
              Row(
                children: [
                  const SizedBox(
                    width: 40,
                  ),
                  Text(
                    'نوع پرداخت',
                    style: const TextStyle(
                      fontFamily: 'sb',
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                      // sty
                      onPressed: () {},
                      child: const Text('پرداخت')),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  _number4Digits(String number) {
    // return number 4 digi 4 digit wit a sapace in between
    if (number.length < 4) return number;
    return '${number.substring(0, 4)} ${number.substring(4, 8)} ${number.substring(8, 12)} ${number.substring(12, 16)}';
  }

  _loadPaymentMethod() async {
    Dio dio = Dio();
    try {
      final res = await dio
          .get('${Utils.base_url}/818_vpn/v1/payment/payment_methods.php');

      setState(() {
        paymentMethods = PaymentMethodResponse.fromJson(res.data).paymentTypes;
      });
    } catch (e) {
      // Utils.showError(context, e.toString());
    }
  }

  _chooseReciptPhotoFromGallery() {
    final ImagePicker picker = ImagePicker();
    picker.pickImage(source: ImageSource.gallery).then((pickedFile) async {
      if (pickedFile != null) {
        // Handle the selected image file, e.g., upload or display
        File imageFile = File(pickedFile.path);
        print(imageFile.path);

        setState(() {
          receiptText = "رسید انتخاب شد";
        });

        if (await _startUpload(imageFile)) {
          // go to ReceiptWaitingRoomPage
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptWaitingRoomPage(
                receiptImage: imageFile,
              ),
            ),
          );

          _check_userSub();
        }
      }
    });
  }

  _check_userSub() async {
    // https://818.arianadevs.com/818_vpn/v1/payment/check_user_sub.php?uid=5CfQJyGiQ0WdMg7h70I3syzK0Zp2
    Dio dio = Dio();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('checking_subscription'),
        ),
      ),
    );
    final box = await Hive.openBox<UserInfo>('users');
    UserInfo? userInfo = box.get('users');
    print(userInfo?.uuid);
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

  _startUpload(File filePath) async {
    String fileName = filePath.path.split('/').last;
    var data = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath.path, filename: fileName),
      'user': Hive.box<UserInfo>('users').get('users')?.uuid ?? '',
      'plan_id': widget.planModelSelected?.id.toString() ?? '1',
    });

    setState(() {
      receiptText = "در حال آپلود رسید";
      receiptStatus = PageStatus.loading;
    });

    try {
      var dio = Dio();
      var response = await dio.request(
        'https://818.arianadevs.com/818_vpn/v1/payment/card_payment.php?action=upload',
        options: Options(
          method: 'POST',
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          receiptText = "با موفقیت آپلود شد";
          receiptStatus = PageStatus.loaded;
        });
        return true;
      }
    } on DioException catch (e) {
      setState(() {
        receiptText = "خط در آپلود ${e.message}";
        receiptStatus = PageStatus.error;
      });
    }
  }
}
