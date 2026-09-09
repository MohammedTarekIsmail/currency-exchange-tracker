import 'package:currency_exchange_tracker/di/injection_container.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/exchange_rates_list_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExchangeRatesListScreen extends StatelessWidget {
  const ExchangeRatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExchangeRatesBloc>()..add(ExchangeRatesStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Exchange Rates')),
        body: const ExchangeRatesListContent(),
      ),
    );
  }
}
