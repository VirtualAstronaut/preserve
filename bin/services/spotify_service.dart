import 'dart:developer';
import 'dart:io';

import 'package:oauth2/oauth2.dart';
import 'package:open_url/open_url.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spotify/spotify.dart';

import '../locator.dart';
import '../models/models.dart';
part 'spotify_service.g.dart';

@Riverpod(keepAlive: true)
SpotifyApiCredentials spotifyCreds(Ref ref) {
  // SpotifyApi? spotify;
  // String? code;
  // AuthorizationCodeGrant? authGrant;
  log('message');
  final appConfig = getItInstance<AppConfig>();
  final credentials = SpotifyApiCredentials(
    appConfig.clientId,
    appConfig.clientSecret,
  );
  return credentials;
}

@Riverpod(keepAlive: true)
class SpotifyService extends _$SpotifyService {
  // final ProviderContainer container;
  // SpotifyApiCredentials? _credentials;
  SpotifyApi? _spotify;
  String? _code;
  static late AuthorizationCodeGrant _authGrant;
  int _pageOffset = 0;
  final _pageLimit = 20;
  final _scopes = [AuthorizationScope.library.read];
  // SpotifyService(this.container);

  Future<void> authorize() async {
    final creds = ref.read(spotifyCredsProvider);
    _authGrant = SpotifyApi.authorizationCodeGrant(creds);
    final authUri = _authGrant.getAuthorizationUrl(
      RedirectUri.uri,
      scopes: _scopes,
    );
    _lauchUrl(authUri);
  }

  Future<List<TrackSaved>> getSavedTracks() async {
    if (_spotify == null) {
      throw Exception('Spotify is null');
    }
    final savedTracksPages = _spotify!.tracks.me.saved;
    final page = await savedTracksPages.getPage(_pageLimit, _pageOffset);
    _pageOffset = page.nextOffset;
    final tracks = page.items?.toList() ?? <TrackSaved>[];
    return tracks;
  }

  void test() async {
    final client = await _authGrant.handleAuthorizationCode(_code!);
    _spotify = SpotifyApi.fromClient(client);
    final results = await getSavedTracks();
    for (var item in results) {
      print(item.track?.name);
    }
  }

  void saveCodeToLocal(String code) {
    this._code = code;
    test();
    final path = getCurrentDirectory();
    const fileName = 'spotify-code';
    final file = File('$path/$fileName');
    file.writeAsString(
      code,
      flush: true,
    );
  }

  @override
  void build() {
    return;
  }

  SpotifyApiCredentials getCreds() {
    final appConfig = getItInstance<AppConfig>();
    return SpotifyApiCredentials(
      appConfig.clientId,
      appConfig.clientSecret,
    );
  }
}

// class SpotifyService {

// }

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
