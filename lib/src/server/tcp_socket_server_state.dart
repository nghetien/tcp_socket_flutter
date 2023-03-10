import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';

class TCPSocketServeState {
  ServerSocket? _serverSocket;
  StreamSubscription<Socket>? _streamSubscriptionServer;
  final Map<String, SocketConnection> _mapIPToSocketConnection = {};
  bool _isInTimeDelay = false;
  bool _serverIsRunning = false;
  final _listenerListSocketConnection =
      StreamController<List<SocketConnection>>.broadcast();

  ServerSocket? get serverSocket => _serverSocket;

  Map<String, SocketConnection> get mapIPToSocketConnection =>
      _mapIPToSocketConnection;

  List<SocketConnection> get listSocketConnection =>
      _mapIPToSocketConnection.values.toList();

  bool get isInTimeDelay => _isInTimeDelay;

  bool get serverIsRunning => _serverIsRunning;

  Stream<List<SocketConnection>> get listenerListSocketConnection =>
      _listenerListSocketConnection.stream;

  void setServerSocket(ServerSocket? value) => _serverSocket = value;

  void setStreamSubscriptionServer(StreamSubscription<Socket>? value) =>
      _streamSubscriptionServer = value;

  void setIsInTimeDelay(bool isInTimeDelay) => _isInTimeDelay = isInTimeDelay;

  void setServerIsRunning(bool serverIsRunning) =>
      _serverIsRunning = serverIsRunning;

  Future closeSocketConnection(SocketConnection socketConnection) =>
      socketConnection.socketChannel.disconnect();

  void removeSocketConnection(String ip) {
    _mapIPToSocketConnection.remove(ip);
    _listenerListSocketConnection.sink.add(listSocketConnection);
  }

  Future checkExistAndRemoveSocketConnection(String ip) async {
    if (_mapIPToSocketConnection.containsKey(ip)) {
      await closeSocketConnection(_mapIPToSocketConnection[ip]!);
      removeSocketConnection(ip);
    }
  }

  void addSocketConnection(ip, SocketConnection socketConnection) {
    _mapIPToSocketConnection[ip] = socketConnection;
    _listenerListSocketConnection.sink.add(listSocketConnection);
    debugPrint('------------------------------------------------------------');
    debugPrint('Server logs - New connection from:');
    debugPrint(socketConnection.deviceInfo.toJsonString());
    debugPrint('------------------------------------------------------------');
  }

  void addDeviceInfoToSocketConnection(
    String ip,
    DeviceInfo deviceInfo,
  ) {
    if (_mapIPToSocketConnection.containsKey(ip)) {
      _mapIPToSocketConnection[ip] = _mapIPToSocketConnection[ip]!.copyWith(
        deviceInfo: deviceInfo,
      );
      _listenerListSocketConnection.sink.add(listSocketConnection);
    }
  }

  Future closeServerSocket() async {
    if (_serverSocket != null) {
      _streamSubscriptionServer!.pause();
      await _streamSubscriptionServer!.cancel();
      await _serverSocket!.close();
      setServerSocket(null);
    }
  }

  Future closeAllSocketConnection() async {
    for (final socketConnection in _mapIPToSocketConnection.values) {
      await closeSocketConnection(socketConnection);
    }
    _mapIPToSocketConnection.clear();
    _listenerListSocketConnection.sink.add(listSocketConnection);
  }
}
