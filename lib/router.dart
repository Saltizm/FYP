import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'main.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const MyHomePage(title: 'Flutter Demo Home Page'),
    ),
    GoRoute(
      path: '/submissions',
      builder: (BuildContext context, GoRouterState state) => const SubmissionsPage(title: 'Submissions Page'),
    )
  ],
);
