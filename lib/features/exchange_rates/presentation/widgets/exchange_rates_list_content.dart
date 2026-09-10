import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_state.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/screens/currency_detail_screen.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/cached_data_banner.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/currency_rate_list_item.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/error_retry_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'exchange_rate_list_loading.dart';

class ExchangeRatesListContent extends StatelessWidget {
  const ExchangeRatesListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRatesBloc, ExchangeRatesState>(
      builder: (context, state) {
        if (state is ExchangeRatesLoading || state is ExchangeRatesInitial) {
          return const ExchangeRatesListLoading();
        }

        if (state is ExchangeRatesError) {
          return ErrorRetryView(
            message: state.message,
            onRetry: () =>
                context.read<ExchangeRatesBloc>().add(ExchangeRatesStarted()),
          );
        }

        if (state is ExchangeRatesEmpty) {
          return const Center(child: Text('No rates available right now.'));
        }

        if (state is ExchangeRatesLoaded) {
          return Column(
            children: [
              if (state.isFromCache) CachedDataBanner(cachedAt: state.cachedAt),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ExchangeRatesBloc>().add(
                      ExchangeRatesRefreshed(),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: state.rates.length,
                    itemBuilder: (context, index) {
                      final rate = state.rates[index];
                      return CurrencyRateListItem(
                        rate: rate,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CurrencyDetailScreen(rate: rate),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
