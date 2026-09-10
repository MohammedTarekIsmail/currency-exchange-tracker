import 'dart:async';
import 'package:currency_exchange_tracker/core/theme/app_palette.dart';
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
          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: _PullableBody(
              child: ErrorRetryView(
                message: 'No exchange rates available right now.',
                icon: Icons.currency_exchange,
                iconColor: context.palette.textSecondary,
                actionLabel: 'Refresh',
                onRetry: () => context.read<ExchangeRatesBloc>().add(
                  ExchangeRatesStarted(),
                ),
              ),
            ),
          );
        }

        if (state is ExchangeRatesLoaded) {
          return Column(
            children: [
              if (state.isFromCache || state.isOffline)
                CachedDataBanner(
                  cachedAt: state.cachedAt,
                  isFromCache: state.isFromCache,
                  isOffline: state.isOffline,
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
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

  Future<void> _refresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<ExchangeRatesBloc>().add(
      ExchangeRatesRefreshed(completer: completer),
    );
    return completer.future;
  }
}

class _PullableBody extends StatelessWidget {
  const _PullableBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
