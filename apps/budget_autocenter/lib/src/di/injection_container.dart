import 'package:core/core.dart';

class AppDependencies {
  AppDependencies._({required this.core});

  final CoreDependencies core;

  static Future<AppDependencies> create() async {
    final core = await CoreDependencies.create();
    return AppDependencies._(core: core);
  }
}
