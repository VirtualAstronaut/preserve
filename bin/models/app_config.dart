import 'dart:io';

import 'package:yaml/yaml.dart';

class AppConfig {
  late final String clientId;
  late final String clientSecret;

  AppConfig() {
    final yamlFile = File('config/config.yaml');
    if (!yamlFile.existsSync()) {
      throw Exception('Please setup file in config/config.yaml');
    }

    final fileString = yamlFile.readAsStringSync();
    final yamlMap = loadYaml(fileString);

    final clientId = yamlMap['client_id'] as String?;
    final clientSecret = yamlMap['client_secret'] as String?;
    if (clientId == null || clientSecret == null) {
      throw Exception('Please Setup client_id and client_secret');
    }
    this.clientId = clientId;
    this.clientSecret = clientSecret;
  }
}
