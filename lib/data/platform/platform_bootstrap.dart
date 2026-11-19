export 'platform_bootstrap_stub.dart'
    if (dart.library.io) 'platform_bootstrap_io.dart'
    if (dart.library.js_interop) 'platform_bootstrap_web.dart';
