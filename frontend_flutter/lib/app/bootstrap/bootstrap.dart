import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../app.dart';
import '../cubit/theme_cubit.dart';
import '../di/injection_container.dart';

Future<void> runApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  // Initialize Dependency Injection
  await initDI();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
