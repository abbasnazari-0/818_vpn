import 'dart:convert';
import 'dart:io';

import 'package:begzar/common/page_status.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart' show Hive;
import 'package:scanning_effect/scanning_effect.dart';

import '../model/user_model.dart';

class ReceiptWaitingRoomPage extends StatefulWidget {
  const ReceiptWaitingRoomPage({super.key, this.receiptImage});

  final File? receiptImage;
  @override
  State<ReceiptWaitingRoomPage> createState() => _ReceiptWaitingRoomPageState();
}

class _ReceiptWaitingRoomPageState extends State<ReceiptWaitingRoomPage> {
  String? status;
  PageStatus pageStatus = PageStatus.loading;
  @override
  void initState() {
    // status = context.tr('processing');
    super.initState();
    _check_every_5_seconds();
  }

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
                  context.tr('processing'),
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
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              child: pageStatus == PageStatus.loading
                  ? ScanningEffect(
                      scanningColor: Colors.red,
                      borderLineColor: Colors.green,
                      delay: Duration(seconds: 1),
                      duration: Duration(seconds: 2),
                      child: Image.file(
                        widget.receiptImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.file(
                      widget.receiptImage!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      colorBlendMode: BlendMode.darken,
                      color: Colors.black.withOpacity(0.4),
                    ),
            ),
            // Lottie.asset('assets/lottie/Animation - 1750969426685.json')
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              // height: 40,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status ?? context.tr('processing'),
                    style: const TextStyle(
                      fontFamily: 'sb',
                      fontSize: 16,
                    ),
                  ),
                  if (pageStatus == PageStatus.loading)
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  if (pageStatus == PageStatus.error)
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  if (pageStatus == PageStatus.loaded)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Center(
            //   child: Text(
            //     context.tr('processing'),
            //     style: const TextStyle(
            //       fontFamily: 'sb',
            //       fontSize: 24,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            if (pageStatus == PageStatus.loading)
              Center(
                child: Text(
                  context.tr('receipt_uploaded_description'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'sb',
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            if (pageStatus == PageStatus.loaded)
              // back to home button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.tr('back_to_home'),
                    style: const TextStyle(
                      fontFamily: 'sb',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool stop = false;
  _check_every_5_seconds() {
    // status = context.tr('processing');
    int totalSeconds = 0;
    // This function will be called every 5 seconds to check the payment status
    Future.delayed(const Duration(seconds: 5), () {
      if (stop) {
        print('Stopped checking payment');
        return;
      }
      // if totalSeconds more than 10 minutes, stop checking
      if (totalSeconds >= 600) {
        print('Stopped checking payment after 10 minutes');
        status = context.tr('upload_receipt_error');
        return;
      }
      totalSeconds += 5;
      _check_payment();
      _check_every_5_seconds(); // Call itself again after 5 seconds
    });
  }

  _check_payment() async {
    try {
      final box = await Hive.openBox<UserInfo>('users');
      UserInfo? userInfo = box.get('users');
      var dio = Dio();
      print(
        {
          'user': userInfo?.uuid,
          'action': 'check', // Example receipt ID, replace with actual
        },
      );
      var response = await dio.get(
        'https://818.arianadevs.com/818_vpn/v1/payment/card_payment.php',
        // options: Options(
        //   method: 'GET',
        // ),
        queryParameters: {
          'user': userInfo?.uuid,
          'action': 'check', // Example receipt ID, replace with actual
        },
      );
      print('Checking payment status... ${response.statusCode}');

      if (response.statusCode == 200) {
        print(json.encode(response.data));
        var data = response.data;
        // if (data['status'] == 'initial') {
        //   // Still processing
        //   setState(() {
        //     status = context.tr('processing');
        //     pageStatus = PageStatus.loading;
        //   });
        if (data['status'] == 'paid') {
          // Payment successful
          stop = true; // Stop checking further
          setState(() {
            status = context.tr('payment_success');
            pageStatus = PageStatus.loaded;
          });
          // Navigate to success page or perform any other action
        } else if (data['status'] == 'unpaid') {
          // Payment failed
          stop = true; // Stop checking further
          setState(() {
            status = context.tr('payment_failed');
            pageStatus = PageStatus.error;
          });
        }
        // setState(() {
        //   status = context.tr('processing');
        //   pageStatus = PageStatus.loading;
        // });
      } else {
        setState(() {
          status = context.tr('upload_receipt_error');
          pageStatus = PageStatus.error;
        });
      }
    } on DioException catch (e) {
      print('Error checking payment status: $e');
      setState(() {
        status = context.tr('upload_receipt_error');
        pageStatus = PageStatus.error;
      });
    }
  }
}
