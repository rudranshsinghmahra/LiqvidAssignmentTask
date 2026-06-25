import 'package:go_router/go_router.dart';
import 'package:liqvid_assignment_rudransh/home/view/home_screen.dart';

import '../home/view/webview_screen.dart';

class AppRouter {
  static final GoRouter routes = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: "Home",
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/player',
        name: "Player",
        builder: (context, state) {
          final htmlPath = state.extra as String;
          return WebViewScreen(htmlFilePath: htmlPath);
        },
      ),
    ],
  );
}
