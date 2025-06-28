import 'package:dio/dio.dart';

class Utils {
  static const enc_key = "IYqSJoHyqHmC8K2jbiGqppR25xjNM2wo";
  static const base_url = "https://818.arianadevs.com/";

  ///convert 123456789 to 123,456,789
  static String seRagham(String number, {String separator = ","}) {
    String str = "";
    var numberSplit = number.split('.');
    number = numberSplit[0].replaceAll(separator, '');
    for (var i = number.length; i > 0;) {
      if (i > 3) {
        str = separator + number.substring(i - 3, i) + str;
      } else {
        str = number.substring(0, i) + str;
      }
      i = i - 3;
    }
    if (numberSplit.length > 1) {
      str += '.' + numberSplit[1];
    }
    return str;
  }

  static Future<Map<String, dynamic>?> getPublicIPInfo() async {
    final url = 'http://ip-api.com/json/';
    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle error if needed
    }
    return null;
  }

  // create a function to convert mb to all other units

  String convertToGBorMB(String usage) {
    usage = usage.trim().toLowerCase();

    double value;
    if (usage.endsWith('gb')) {
      value = double.tryParse(usage.replaceAll('gb', '').trim()) ?? 0.0;
    } else if (usage.endsWith('mb')) {
      value =
          (double.tryParse(usage.replaceAll('mb', '').trim()) ?? 0.0) / 1024;
    } else {
      value = (double.tryParse(usage) ?? 0.0) / 1024;
    }

    if (value < 1) {
      // Return as MB
      double mbValue = value * 1024;
      return "${mbValue.toStringAsFixed(2)} MB";
    } else {
      // Return as GB
      return "${value.toStringAsFixed(2)} GB";
    }
  }
}
