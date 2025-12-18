import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ConnectionState { connected, disconnected, error }

class ConnectionBloc extends Cubit<ConnectionState> {
  final InternetConnectionChecker _connectionChecker;

  ConnectionBloc(this._connectionChecker) : super(ConnectionState.connected) {
    _monitorConnection();
  }

  void _monitorConnection() {
    _connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        emit(ConnectionState.connected);
      } else {
        emit(ConnectionState.disconnected);
      }
    });
  }
}