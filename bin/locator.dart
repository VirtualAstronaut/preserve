import 'package:get_it/get_it.dart';

import 'models/app_config.dart';
import 'services/services.dart';

final getItInstance = GetIt.instance;

void locatorSetup() {
  getItInstance.registerSingleton<AppConfig>(AppConfig());
  getItInstance.registerSingleton<SpotifyService>(SpotifyService());
}
