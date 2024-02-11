import 'dart:io';

import 'package:oauth2/oauth2.dart';
import 'package:open_url/open_url.dart';
import 'package:spotify/spotify.dart';

import '../locator.dart';
import '../models/app_config.dart';
import 'services.dart';

class SpotifyService {
  SpotifyApiCredentials? _credentials;
  String? _redirectUri;
  SpotifyApi? spotify;
  String? code;
  AuthorizationCodeGrant? authGrant;
  int _pageOffset = 0;
  final _pageLimit = 20;

  SpotifyService() {
    final appConfig = getItInstance<AppConfig>();
    _redirectUri = appConfig.redirectUri;
    _credentials = SpotifyApiCredentials(
      appConfig.clientId,
      appConfig.clientSecret,
    );
  }

  Future<void> authorize() async {
    if (_credentials == null || _redirectUri == null) {
      throw Exception('_credentials or _redirectUri is null');
    }
    authGrant = SpotifyApi.authorizationCodeGrant(_credentials!);

    final authUri = authGrant!.getAuthorizationUrl(
      Uri.parse(_redirectUri!),
      scopes: _scopes,
    );
    _lauchUrl(authUri);
  }

  Future<List<TrackSaved>> getSavedTracks() async {
    if (spotify == null) {
      throw Exception('Spotify is null');
    }
    final savedTracksPages = spotify!.tracks.me.saved;
    final page = await savedTracksPages.getPage(_pageLimit, _pageOffset);
    _pageOffset = page.nextOffset;
    final tracks = page.items?.toList() ?? <TrackSaved>[];
    return tracks;
  }

  void test() async {
    final client = await authGrant!.handleAuthorizationCode(code!);
    spotify = SpotifyApi.fromClient(client);
    final results = await getSavedTracks();
    for (var item in results) {
      print(item.track?.name);
    }
  }

  void saveCodeToLocal(String code) {
    this.code = code;
    test();
    final path = getCurrentDirectory();
    const fileName = 'spotify-code';
    final file = File('$path/$fileName');
    file.writeAsString(
      code,
      flush: true,
    );
  }
}

String getCurrentDirectory() {
  final currentDir = Directory.current;
  return currentDir.path;
}

void _lauchUrl(Uri uri) async {
  final result = await openUrl(uri.toString());
  if (result.exitCode != 0) {
    print('something went wrong while opening browser');
    print('exit code ${result.exitCode}');
    print('stack trace ${result.stderr}');
  }
  print('URL should be opened in browser');
  print('or else copy pasta this link in browser to authenticate');
  print('-' * 10);
  print(uri.toString());
}

final _scopes = [AuthorizationScope.library.read];
