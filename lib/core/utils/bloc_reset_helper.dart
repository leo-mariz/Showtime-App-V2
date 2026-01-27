import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/artist_dashboard/presentation/bloc/events/artist_dashboard_events.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_bank_account/presentation/bloc/events/bank_account_events.dart';
import 'package:app/features/profile/artist_documents/presentation/bloc/events/documents_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/profile/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/artist_dashboard/presentation/bloc/artist_dashboard_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_bank_account/presentation/bloc/bank_account_bloc.dart';
import 'package:app/features/profile/artist_documents/presentation/bloc/documents_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/groups/presentation/bloc/events/groups_events.dart';
import 'package:app/features/profile/groups/presentation/bloc/groups_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/chat/presentation/bloc/chats_list/chats_list_bloc.dart';
import 'package:app/features/chat/presentation/bloc/chats_list/events/chats_list_events.dart';
import 'package:app/features/chat/presentation/bloc/messages/messages_bloc.dart';
import 'package:app/features/chat/presentation/bloc/messages/events/messages_events.dart';

/// Helper para resetar todos os BLoCs ao estado inicial
/// 
/// Utilizado principalmente após logout para garantir que todos os BLoCs
/// sejam resetados e subscriptions/timers sejam cancelados
class BlocResetHelper {
  /// Reseta todos os BLoCs ao estado inicial
  /// 
  /// Cancela subscriptions, timers e emite estados iniciais para:
  /// - ChatsListBloc
  /// - MessagesBloc
  /// - AuthBloc
  /// 
  /// Outros BLoCs podem ser adicionados conforme necessário
  static void resetAllBlocs(BuildContext context) {
    
    try {
      // Resetar AddressesBloc (cancela stream de endereços)
      context.read<AddressesBloc>().add(ResetAddressesEvent());
      // Resetar UsersBloc (cancela stream de usuários)
      context.read<UsersBloc>().add(ResetUsersEvent());
      // Resetar ClientsBloc (cancela stream de clientes)
      context.read<ClientsBloc>().add(ResetClientsEvent());
      // Resetar ArtistsBloc (cancela stream de artistas)
      context.read<ArtistsBloc>().add(ResetArtistsEvent());
      // Resetar DocumentsBloc (cancela stream de documentos)
      context.read<DocumentsBloc>().add(ResetDocumentsEvent());
      // Resetar GroupsBloc (cancela stream de grupos)
      context.read<GroupsBloc>().add(ResetGroupsEvent());
      // Resetar AvailabilityBloc (cancela stream de disponibilidade)
      context.read<AvailabilityBloc>().add(ResetAvailabilityEvent());
      // Resetar BankAccountBloc (cancela stream de conta bancária)
      context.read<BankAccountBloc>().add(ResetBankAccountEvent());
      // Resetar ContractsBloc (cancela stream de contratos)
      context.read<ContractsBloc>().add(ResetContractsEvent());
      // Resetar FavoritesBloc (cancela stream de favoritos)
      context.read<FavoritesBloc>().add(ResetFavoritesEvent());
      // Resetar ExploreBloc (cancela stream de explore)
      context.read<ExploreBloc>().add(ResetExploreEvent());
      // Resetar AppListsBloc (cancela stream de listas de apps)
      context.read<AppListsBloc>().add(ResetAppListsEvent());
      // Resetar ArtistDashboardBloc (cancela stream de dashboard de artistas)
      context.read<ArtistDashboardBloc>().add(ResetArtistDashboardEvent()); 
      // Resetar ChatsListBloc (cancela stream de chats)
      context.read<ChatsListBloc>().add(ResetChatsListEvent());
      // Resetar MessagesBloc (cancela stream de mensagens e timer de digitação)
      context.read<MessagesBloc>().add(ResetMessagesEvent());
      // Resetar AuthBloc para AuthInitial (deve ser o último)
      context.read<AuthBloc>().add(ResetAuthEvent());
    } catch (e) {
      // Se algum BLoC não estiver disponível, apenas logar o erro
      // Não quebrar o fluxo de logout
      debugPrint('Erro ao resetar BLoCs: $e');
    }
  }
}
