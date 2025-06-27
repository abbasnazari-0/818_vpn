import 'package:begzar/common/page_status.dart';
import 'package:begzar/common/theme.dart';
import 'package:begzar/common/utils.dart';
import 'package:begzar/model/subscribtion_model.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/screens/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

class CodeInputerDialog extends StatefulWidget {
  final double width;
  final double height;

  const CodeInputerDialog({super.key, this.width = 300, this.height = 200});

  @override
  State<CodeInputerDialog> createState() => _CodeInputerDialogState();
}

class _CodeInputerDialogState extends State<CodeInputerDialog> {
  TextEditingController codeController = TextEditingController();
  PageStatus codeVerifireStatus = PageStatus.initial;
  String erroText = '';

  onCodeSubmit() {
    if (codeController.text.isEmpty) {
      // نمایش خطا یا پیام مناسب
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('insert_code'))),
      );
      return;
    }

    // اینجا می‌تونی کد رو ارسال کنی یا هر کاری که لازم هست انجام بدی
    // print('کد وارد شده: ${codeController.text}');

    // if code  length is not 6
    // if (codeController.text.length != 6) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('کد نامعتبر است')),
    //   );
    //   return;
    // }

    _codeVerifire(codeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeColor.backgroundColor,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: widget.width,
        // height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // این باعث میشه محتوا اندازه رو تنظیم کنه اگر height ندی
          children: [
            Text(
              context.tr('insert_code'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 16),
            const SizedBox(height: 50),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: context.tr('insert_code'),
                border: const OutlineInputBorder(),
                // icon: Icon(Icons.code),
                prefixIcon: Icon(Iconsax.lock,
                    size: 20, color: ThemeColor.foregroundColor),
              ),
            ),

            const SizedBox(height: 50),

            Text(
              erroText,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            if (codeVerifireStatus == PageStatus.loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.foregroundColor,
                  foregroundColor: ThemeColor.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // textStyle: const TextStyle(fontSize: 16),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(context.tr('submit')),
                onPressed: () {
                  // اقدام لازم هنگام تایید
                  // Navigator.of(context).pop();
                  onCodeSubmit();
                },
              )
          ],
        ),
      ),
    );
  }

  _codeVerifire(String code) async {
    // اینجا می‌تونی کد رو به سرور ارسال کنی و نتیجه رو بررسی کنی
    // برای مثال:
    // final box = await Hive.openBox<UserInfo>('users');
    // final userInfo = box.get('users');

    setState(() {
      codeVerifireStatus = PageStatus.loading;
    });

    try {
      Dio dio = Dio();
      print('${Utils.base_url}/818_vpn/v1/subscription/use-code.php');
      // dio.options.headers['Content-Type'] = 'application/json';
      final res = await dio.post(
          '${Utils.base_url}/818_vpn/v1/subscription/use-code.php',
          data: {
            'code': code,
          },
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));

      print('Response: ${res.data}');

      if (res.statusCode == 200) {
        // اگر کد معتبر بود
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('کد معتبر است')),
        // );
        // Navigator.of(context).pop(); // بستن دیالوگ

        UserInfo userInfo = UserInfo.fromJson(res.data);
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
      }

      setState(() {
        codeVerifireStatus = PageStatus.loaded;
      });
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404:
          // در صورت بروز خطا
          setState(() {
            codeVerifireStatus = PageStatus.loaded;
            erroText = context.tr('code_not_usable');
          });
          break;
        default:
      }

      // after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          codeVerifireStatus = PageStatus.initial;
          erroText = '';
        });
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('خطا در ارسال کد: $error')),
      // );
    }
    // if error

    // }).catchError((error) {
    //   // در صورت بروز خطا
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('خطا در ارسال کد: $error')),
    //   );
    // });
    // codeVerifire(code).then((response) {
    //   if (response.statusCode == 200) {
    //     // اگر کد معتبر بود
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('کد معتبر است')),
    //     );
    //     Navigator.of(context).pop(); // بستن دیالوگ
    //   } else {
    //     // اگر کد نامعتبر بود
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('کد نامعتبر است')),
    //     );
    //   }
    // }).catchError((error) {
    //   // در صورت بروز خطا
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('خطا در ارسال کد: $error')),
    //   );
    // });

    setState(() {
      codeVerifireStatus = PageStatus.initial;
      // erroText = '';
    });
  }
}
