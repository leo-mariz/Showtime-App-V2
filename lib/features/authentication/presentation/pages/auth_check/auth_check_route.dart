// import 'package:app/core/config/auto_router_config.gr.dart';
// import 'package:app/features/authentication/presentation/bloc/events/users_events.dart';
// import 'package:app/features/authentication/presentation/bloc/states/users_states.dart';
// import 'package:app/features/authentication/presentation/bloc/users_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// @RoutePage()
// class AuthCheckRoute extends StatefulWidget {
//   const AuthCheckRoute({super.key});

//   @override
//   State<AuthCheckRoute> createState() => _AuthCheckRouteState();
// }

// class _AuthCheckRouteState extends State<AuthCheckRoute> {

//   @override
//   void initState() {
//     super.initState();
//     context.read<UsersBloc>().add(CheckUserLoggedInEvent());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final router = AutoRouter.of(context);
//     return BlocListener<UsersBloc, UsersState>(
//       listener: (context, state) {
//         if (state is CheckUserLoggedInSuccess) {
//           final isLoggedIn = state.isLoggedIn;
//           if (isLoggedIn) {
//             router.replace(HomeRoute(isArtist: state.isArtist));
//           } else {
//             router.replace(const InitialRoute());
//           }
//         } else if (state is UsersFailure) {
//           router.replace(const InitialRoute());
//         }
//       },
//       child: const LoadingIndicator(),
//     );
//   }
// }