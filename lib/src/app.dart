import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'features/login/login_screen.dart';
import 'features/shell/main_shell.dart';
import 'state/auth_controller.dart';
import 'services/local_storage.dart';
import 'theme/app_theme.dart';
import 'utils/app_snackbar.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.storage});

  final LocalStorage storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(storage)),
      ],
      child: MaterialApp(
        title: 'Trouve Ton Alternance',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        scaffoldMessengerKey: AppSnackbar.messengerKey,
        home: const TokenExpiredHandler(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.hydrated) {
          return const _HydrationScreen();
        }
        if (auth.user == null) {
          return const LoginScreen();
        }
        return const MainShell();
      },
    );
  }
}

class TokenExpiredHandler extends StatelessWidget {
  const TokenExpiredHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        if (auth.user == null) {
          return const LoginScreen();
        }
        return child!;
      },
      child: const MainShell(),
    );
  }
}

class _HydrationScreen extends StatelessWidget {
  const _HydrationScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text('Initialisation de votre session…'),
          ],
        ),
      ),
    );
  }
}
