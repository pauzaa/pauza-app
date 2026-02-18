import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/common/const/assets.gen.dart';

extension $PauzaConfigX on BuildContext {
  // BazmConfig get appEnv => readSettings.getCurrentConfig<BazmConfig>()!;
}

class PauzaConfig extends JsonAssetConfig {
  PauzaConfig({
    required super.path,
    required super.name,
    required super.color,
    super.showBanner,
  });

  bool get isProd {
    if (name.toLowerCase() == 'production') return true;
    return false;
  }

  String get appName => getString('APP_NAME');

  String get apiBaseUrl => getString('API_BASE_URL');
}

class ProdConfig extends PauzaConfig {
  ProdConfig()
    : super(
        name: 'production',
        path: Assets.config.prod,
        color: Colors.green,
        showBanner: true,
      );
}

class TestConfig extends PauzaConfig {
  TestConfig()
    : super(
        name: 'testing',
        path: Assets.config.test,
        color: Colors.red,
        showBanner: false,
      );
}
