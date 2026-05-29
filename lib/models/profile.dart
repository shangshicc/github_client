import 'package:github_client_app/models/index.dart';
import 'package:json_annotation/json_annotation.dart';
part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  User? user;
  String? token;

  /// 历史主题色字段，保留用于兼容旧版本本地数据。
  num theme = 5678;

  /// 当前选中的皮肤标识。
  String? skinId;

  String? themeMode;
  CacheConfig? cache;
  String? lastLogin;
  String? locale;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
