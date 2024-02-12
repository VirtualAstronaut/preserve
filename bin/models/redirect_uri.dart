class RedirectUri {
  static const _uri = 'http://localhost:6969/spotify-auth';
  static get uriString => _uri;
  static Uri get uri => Uri.parse(_uri);
  static String withPort(int port) {
    return _uri.replaceFirst(r'\d', port.toString());
  }
}
