import 'package:flutter_v2ray/flutter_v2ray.dart';

class ServerModel {
  final int id;
  final String location;
  final String config;
  final String created_at;
  final String country_code;
  final bool? isPremium; // default value

  int? pingTime;

  ServerModel(
    this.created_at,
    this.country_code, {
    required this.id,
    required this.location,
    required this.config,
    this.pingTime = -2,
    this.isPremium = false,
  });

  @override
  String toString() {
    return 'ServerList{id: $id, location: $location, config: $config}, isPremium: $isPremium, pingTime: $pingTime, created_at: $created_at, country_code: $country_code}';
  }

  String fullConfiguration() {
    V2RayURL parser = FlutterV2ray.parseFromURL(config);
    return parser.getFullConfiguration();
  }

  // empty constructor
  ServerModel.empty()
      : id = 0,
        location = 'Automatic',
        config = '',
        created_at = '',
        country_code = '',
        isPremium = false,
        pingTime = null;

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    final bool isVless = false;
    return ServerModel(json['created_at'] ?? '', json['country_code'],
        id: json['id'] ?? 0,
        location: json['location'],
        config: json['config'],
        isPremium: json['is_premium'] ?? false,
        // vlessInfo: isVless ? VlessInfo.fromJson(json['config']) : null,
        pingTime: json['pingTime'] ?? -2);
  }

  static String locationExtractor(link) {
    V2RayURL parser = FlutterV2ray.parseFromURL(link);

    return parser.remark;
  } //should extract the location from the vless config

  factory ServerModel.fromString(String jsonString) {
    return ServerModel(
      "",
      '',
      id: 0,
      location: locationExtractor(jsonString),
      config: jsonString,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['location'] = location;
    data['config'] = config;
    data['created_at'] = created_at;
    data['country_code'] = country_code;

    data['pingTime'] = pingTime ?? -2;
    return data;
  }

  // get short location
  String getShortLocation() {
    if (location.length > 10) {
      return '${location.substring(0, 10)}...';
    }
    return location;
  }

  ServerModel copyWith({
    int? id,
    String? location,
    String? config,
    String? createdAt,
    String? countryCode,
  }) {
    return ServerModel(
      createdAt ?? created_at,
      countryCode ?? country_code,
      id: id ?? this.id,
      location: location ?? this.location,
      config: config ?? this.config,
    );
  }

  // from map
  static ServerModel fromMap(Map<String, dynamic> map) {
    return ServerModel(
      map['created_at'],
      map['country_code'],

      id: map['id'],
      location: map['location'],
      config: map['config'], // corrected 'configs' to 'config'
    );
  }
}
