import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SupportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SupportInitial extends SupportState {}

class SendSupportMessageLoading extends SupportState {}

class SendSupportMessageSuccess extends SupportState {
  final SupportRequestEntity request;

  SendSupportMessageSuccess({required this.request});

  @override
  List<Object?> get props => [request];
}

class SendSupportMessageFailure extends SupportState {
  final String error;

  SendSupportMessageFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
