import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../locator.dart';
import 'services.dart';

const _hostName = 'localhost';
late final HttpServer _server;

int _checkPort(portFromCmd) {
  var portStr = portFromCmd ?? Platform.environment['PORT'] ?? '6969';
  var port = int.tryParse(portStr);
  if (port == null) {
    stdout.writeln('Could not use parse "$port" please use number duh');
    exitCode = 64;
    return exitCode;
  }
  return port;
}

Router _setupRouter() {
  final app = Router();
  const spotifyAuth = '/spotify-auth';
  app.get(spotifyAuth, _spotifyAuthHandler);
  return app;
}

Future<Response> _spotifyAuthHandler(Request request) async {
  final queryParams = request.url.queryParameters;
  print('request queryParams ${request.url.queryParameters}');
  final code = queryParams['code'];
  if (code == null) {
    print('error: spotify code is null');
    throw Exception('spotify code is null');
  }
  final spotifyService = getItInstance<SpotifyService>();
  spotifyService.saveCodeToLocal(code);
  // stopServer();
  return Response.ok('');
}

void startServer(ArgResults result) async {
  final port = _checkPort(result['port']);
  final router = _setupRouter();

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router);

  _server = await serve(handler, _hostName, port);
  print('server at http://${_server.address.host}:${_server.port}');
}

void stopServer() {
  _server.close();
}
