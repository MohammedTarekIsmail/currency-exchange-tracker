import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates_state.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/currency_rate_list_item.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/exchange_rate_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExchangeRatesListContent extends StatelessWidget {
  const ExchangeRatesListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRatesBloc, ExchangeRatesState>(
      builder: (context, state) {
        if (state is ExchangeRatesLoading || state is ExchangeRatesInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ExchangeRatesError) {
          return ExchangeRateErrorView(message: state.message);
        }

        if (state is ExchangeRatesEmpty) {
          return const Center(child: Text('No rates available right now.'));
        }

        if (state is ExchangeRatesLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExchangeRatesBloc>().add(ExchangeRatesRefreshed());
            },
            child: ListView.builder(
              itemCount: state.rates.length,
              itemBuilder: (context, index) {
                final rate = state.rates[index];
                return CurrencyRateListItem(rate: rate, onTap: () {});
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
