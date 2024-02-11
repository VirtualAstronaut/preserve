import 'dart:io';

import 'package:yaml/yaml.dart';

class AppConfig {
  late final String clientId;
  late final String clientSecret;
  late final String redirectUri;
  AppConfig() {
    final yamlFile = File('config/config.yaml');
    final fileString = yamlFile.readAsStringSync();
    final yamlMap = loadYaml(fileString);
    clientId = yamlMap['client_id'];
    clientSecret = yamlMap['client_secret'];
    redirectUri = yamlMap['redirectUri'];
  }
}
