// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.4.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `send`

Future<String> sendRequest(
        {required String method,
        required Map<String, String> headers,
        required String url,
        required String payload}) =>
    RustLib.instance.api.crateApiUtilsHttpHelperSendRequest(
        method: method, headers: headers, url: url, payload: payload);
