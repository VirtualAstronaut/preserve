import 'package:args/args.dart';
import 'package:riverpod/riverpod.dart';

import 'locator.dart';
import 'services/services.dart';

void main(List<String> arguments) {
  final container = ProviderContainer();
  locatorSetup();

  final parser = ArgParser()..addOption('port', abbr: 'p');
  final result = parser.parse(arguments);
  startServer(result);

  final spotifyService = container.read(spotifyServiceProvider.notifier);
  spotifyService.authorize();
}
