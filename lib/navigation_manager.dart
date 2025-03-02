
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'fullsize.dart';
import 'home.dart';
import 'init_view.dart';

class NavigationManager {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/init',
      errorBuilder: (context, state) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.error}'),
              ],
            ),
          ),
        );
      },
      routes: [
        ShellRoute(builder: (context, state, navigator) {
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {},
              child: Scaffold(body: navigator));
        }, routes: [
          GoRoute(
            path: '/home',
            builder: (BuildContext _, GoRouterState _) => const HomeScreen(),
          ),
        ],
        ),
        GoRoute(
          path: '/init',
          builder: (BuildContext _, GoRouterState _) => InitView(),
        ),
        GoRoute(
          name: 'fullsize',
          path: '/fullsize/:goto',
          builder: (BuildContext context, GoRouterState state) {
            final primaryUrl = state.uri.queryParameters['goto'] ?? '';
            final fallbackUrl = state.uri.queryParameters['path'] ?? '';

            return FullSize(primaryUrl: primaryUrl, fallbackUrl: fallbackUrl);
          },
        ),
      ]
  );

}