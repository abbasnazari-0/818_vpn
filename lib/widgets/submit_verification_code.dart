import 'package:begzar/common/page_status.dart';
import 'package:begzar/common/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class SubmitVerificationCode extends StatefulWidget {
  SubmitVerificationCode({super.key});

  @override
  State<SubmitVerificationCode> createState() => _SubmitVerificationCodeState();
}

class _SubmitVerificationCodeState extends State<SubmitVerificationCode> {
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    checkEmailVerification();
  }

  checkEmailVerification() async {
    // loop check 5 seconds for email verification
    int attempts = 0;
    while (FirebaseAuth.instance.currentUser?.emailVerified == false) {
      FirebaseAuth.instance.currentUser?.reload();
      await Future.delayed(const Duration(seconds: 5));
      attempts++;
    }
    if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
      // email is verified
      Navigator.of(context).pop(
        <String, String>{
          'status': 'success',
          'message': context.tr('email_verified')
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('email_verified'))),
      );
    } else {
      // email is not verified after 5 attempts
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('email_not_verified'))),
      );
    }
  }

  String erroText = '';
  PageStatus codeVerifireStatus = PageStatus.initial;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ThemeColor.backgroundColor,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
            width: double.infinity,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  context.tr('email_verification'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // const SizedBox(height: 16),
                const SizedBox(height: 50),
                // TextField(
                //   controller: codeController,
                //   decoration: InputDecoration(
                //     hintText: context.tr('insert_code'),
                //     border: const OutlineInputBorder(),
                //     // icon: Icon(Icons.code),
                //     prefixIcon: Icon(Iconsax.lock,
                //         size: 20, color: ThemeColor.foregroundColor),
                //   ),
                // ),

                Lottie.asset(
                  'assets/lottie/Animation - 1750761871923.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                  repeat: true,
                ),

                const SizedBox(height: 30),
                Text(
                  context.tr('email_verification_description'),
                  // style: const TextStyle(color: Colors.red),
                ),

                // Text(
                //   erroText,
                //   style: const TextStyle(color: Colors.red),
                // ),
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
                    child: Text(context.tr('send_again')),
                    onPressed: () {
                      FirebaseAuth.instance.currentUser
                          ?.sendEmailVerification();
                      // اقدام لازم هنگام تایید
                      // Navigator.of(context).pop();
                      // onCodeSubmit();
                    },
                  )
              ],
            )));
  }
}
