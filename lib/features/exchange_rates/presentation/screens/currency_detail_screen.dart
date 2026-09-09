import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/currency_detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:currency_exchange_tracker/di/injection_container.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_event.dart';

class CurrencyDetailScreen extends StatelessWidget {
  final CurrencyRate rate;

  const CurrencyDetailScreen({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CurrencyDetailBloc>()
        ..add(FetchHistoricalRates(rate.code)),
      child: Scaffold(
        appBar: AppBar(title: Text(rate.name)),
        body: CurrencyDetailContent(rate: rate),
      ),
    );
  }
}