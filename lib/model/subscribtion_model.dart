import 'package:hive/hive.dart';

part 'subscribtion_model.g.dart'; // برای ساخت آداپتر

@HiveType(typeId: 1)
class SubscribtionModel {
  // "plan_name": "یک ماهه",
  // "start": "2025-06-23 18:51:29",
  // "end": "2025-07-23 18:51:29"

  @HiveField(1)
  String planName;
  @HiveField(2)
  String? start;
  @HiveField(3)
  String? end;
  @HiveField(4)
  MassSubModel? mass;

  SubscribtionModel({
    required this.planName,
    required this.start,
    required this.end,
    required this.mass,
  });

  // empty
  SubscribtionModel.empty()
      : planName = '',
        start = null,
        end = null,
        mass = null;

  // from json
  factory SubscribtionModel.fromJson(Map<String, dynamic> json) {
    return SubscribtionModel(
      planName: json['plan_name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      mass: json['mass'] != null
          ? MassSubModel.fromJson(json['mass'])
          : MassSubModel.empty(),
    );
  }

  // has active subscribtion
  hasActiveSub() {
    // check for end date
    if (end == null) return false;
    if (end!.isEmpty) return false;
    try {
      final endDate = DateTime.parse(end!);
      return endDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // get reminded day
  int getRemindedDay() {
    if (end == null) return 0;
    try {
      final endDate = DateTime.parse(end!);
      final now = DateTime.now();
      final difference = endDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  // get start date like: 2025-05-21
  String getFormattedStartDate() {
    if (start == null) return '';
    if (start!.isEmpty) return '';
    try {
      final startDate = DateTime.parse(start!);
      return "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  //  get end date like: 2025-05-21
  String getFormattedEndDate() {
    if (end == null) return '';
    if (end!.isEmpty) return '';
    try {
      final endDate = DateTime.parse(end!);
      return "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  // get good format start date and end date like this: ۲۳ ژوئن → ۲۳ جولای
  String getFormattedRangeFa() {
    if (start == null || end == null) return '';
    try {
      final startDate = DateTime.parse(start!);
      final endDate = DateTime.parse(end!);

      final faMonths = [
        'ژانویه',
        'فوریه',
        'مارس',
        'آوریل',
        'مه',
        'ژوئن',
        'جولای',
        'اوت',
        'سپتامبر',
        'اکتبر',
        'نوامبر',
        'دسامبر'
      ];

      String toPersianNumber(int number) {
        const persianDigits = [
          '۰',
          '۱',
          '۲',
          '۳',
          '۴',
          '۵',
          '۶',
          '۷',
          '۸',
          '۹'
        ];
        return number
            .toString()
            .split('')
            .map((e) => persianDigits[int.parse(e)])
            .join();
      }

      String startDay = toPersianNumber(startDate.day);
      String startMonth = faMonths[startDate.month - 1];
      String endDay = toPersianNumber(endDate.day);
      String endMonth = faMonths[endDate.month - 1];

      return '$startDay $startMonth → $endDay $endMonth';
    } catch (e) {
      return '';
    }
  }

  // get progress date  from 0 to 1
  double getProgress() {
    if (start == null || end == null) return 0.0;
    try {
      final startDate = DateTime.parse(start!);
      final endDate = DateTime.parse(end!);
      final now = DateTime.now();

      if (now.isBefore(startDate)) return 0.0;
      if (now.isAfter(endDate)) return 1.0;

      final totalDuration = endDate.difference(startDate).inSeconds;
      final elapsed = now.difference(startDate).inSeconds;

      if (totalDuration <= 0) return 0.0;

      return elapsed / totalDuration;
    } catch (e) {
      return 0.0;
    }
  }
}

@HiveType(typeId: 3)
class MassSubModel {
  // "mass": {
  //           "used_volume": "238.63",
  //           "total_volume": "20"
  //       }

  @HiveField(1)
  String usedVolume;
  @HiveField(2)
  String totalVolume;
  MassSubModel({
    required this.usedVolume,
    required this.totalVolume,
  });

  // empty
  MassSubModel.empty()
      : usedVolume = '',
        totalVolume = '';

  // from json
  factory MassSubModel.fromJson(Map<String, dynamic> json) {
    return MassSubModel(
      usedVolume: json['used_volume'] ?? '',
      totalVolume: json['total_volume'] ?? '',
    );
  }

  // get used volume as double
  double getUsedVolume() {
    try {
      return double.parse(usedVolume);
    } catch (e) {
      return 0.0;
    }
  }

  // get total volume as double
  double getTotalVolume() {
    try {
      return double.parse(totalVolume);
    } catch (e) {
      return 0.0;
    }
  }

  // get progress as double
  double getProgress() {
    final used = getUsedVolume();
    final total = getTotalVolume();
    if (total <= 0) return 0.0;
    return (used / total).clamp(0.0, 1.0);
  }
}
