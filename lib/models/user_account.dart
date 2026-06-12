// lib/models/user_account.dart
import 'package:hive/hive.dart';

part 'user_account.g.dart';

@HiveType(typeId: 1) // Using typeId 1 to completely avoid colliding with Recipe (typeId 0)
class UserAccount extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String passwordHash;

  UserAccount({required this.username, required this.passwordHash});
}