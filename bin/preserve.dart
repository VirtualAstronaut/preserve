import 'package:args/args.dart';

import 'locator.dart';
import 'services/services.dart';

void main(List<String> arguments) {
  locatorSetup();

  final parser = ArgParser()..addOption('port', abbr: 'p');
  final result = parser.parse(arguments);
  startServer(result);

  final spotifyModel = getItInstance<SpotifyService>();
  spotifyModel.authorize();
}
