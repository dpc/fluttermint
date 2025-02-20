// This file initializes the dynamic library and connects it with the stub
// generated by flutter_rust_bridge_codegen.

import 'dart:ffi';

import 'package:path_provider/path_provider.dart';

import 'client.dart';
import 'bridge_generated.dart';
import 'dart:io' as io;

const _base = 'minimint_bridge';

// On MacOS, the dynamic library is not bundled with the binary,
// but rather directly **linked** against the binary.
final _dylib = io.Platform.isWindows ? '$_base.dll' : 'lib$_base.so';

class MinimintClientImpl implements MinimintClient {
  // The late modifier delays initializing the value until it is actually needed,
  // leaving precious little time for the program to quickly start up.
  late final MinimintBridge api = MinimintBridgeImpl(
      io.Platform.isIOS || io.Platform.isMacOS
          ? DynamicLibrary.executable()
          : DynamicLibrary.open(_dylib));

  /// If this returns Some, user has joined a federation. Otherwise they haven't.
  @override
  Future<ConnectionStatus> init() async {
    final userDir = await getApplicationDocumentsDirectory();
    return api.init(path: userDir.path);
  }

  @override
  Future<void> joinFederation({required String configUrl}) async {
    final userDir = await getApplicationDocumentsDirectory();
    await api.joinFederation(configUrl: configUrl, userDir: userDir.path);
  }

  @override
  Future<void> leaveFederation() {
    return api.leaveFederation();
  }

  @override
  Future<int> balance() {
    return api.balance();
  }

  @override
  Future<void> pay({required String bolt11}) {
    return api.pay(bolt11: bolt11);
  }

  @override
  Future<BridgeInvoice> decodeInvoice({required String bolt11}) {
    return api.decodeInvoice(bolt11: bolt11);
  }

  @override
  Future<String> invoice({required int amount, required String description}) {
    return api.invoice(amount: amount, description: description);
  }

  @override
  Future<BridgePayment> fetchPayment(
      {required String paymentHash, dynamic hint}) {
    return api.fetchPayment(paymentHash: paymentHash);
  }

  @override
  Future<List<BridgePayment>> fetchPayments() {
    return api.listPayments();
  }

  @override
  Future<ConnectionStatus> connectionStatus() {
    return api.connectionStatus();
  }

  @override
  Future<String> network() {
    return api.network();
  }
}
