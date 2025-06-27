import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // برای ساخت آداپتر

@HiveType(typeId: 0)
@JsonSerializable()
class UserInfo extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  String token;
  @HiveField(4)
  String uuid;

  UserInfo(
      {required this.name,
      required this.email,
      required this.token,
      required this.uuid});

  // from json : model s1ample: I/flutter (19316): {message: Login successful, user: {uid: ZYOWSViFDBg6Zw9NSKl1KZdcv1o2, email: a3@a.com, name: ss, active_token: 389fdea3f47450c42ee52710d72bce1d04291d00550706c05b58e40a6e2f6a9b}}

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    print('UserInfo.fromJson: $json');
    return UserInfo(
      name: json['user']['name'] ?? '',
      email: json['user']['email'] ?? '',
      token: json['user']['active_token'] ?? '',
      uuid: json['user']['uid'] ?? '',
    );
  }
}
