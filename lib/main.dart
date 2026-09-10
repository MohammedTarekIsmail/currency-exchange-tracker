import 'package:currency_exchange_tracker/features/exchange_rates/presentation/screens/exchange_rates_list_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Exchange App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ExchangeRatesListScreen(),
    );
  }
}
