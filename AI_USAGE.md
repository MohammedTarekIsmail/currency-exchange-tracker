# AI Usage Log

This document tracks how AI was used throughout this project, end to end.
Each entry includes: the prompt, what the AI returned, and whether it was
accepted, edited, or rejected — and why. (I used my own personal Claude Pro account.)

---

## Prompt: Read ASSIGNMENT.md and AI_USAGE.md for context before building

**Full prompt:** Before we start building, read ASSIGNMENT.md in the project root, that's the full
spec for what I'm making. Also check AI_USAGE.md so you know the format Im logging in. Confirm you
have read both and give me a quick summary of the app so I know you have got it right before I give
you the actual build instructions. Then append an entry to AI_USAGE.md for this step so I can make
sure that you read ASSIGNMENT.md and AI_USAGE.md to get context before starting any actual coding.
**AI response summary:** Read both files. Summarized the app: a Flutter Currency Exchange Tracker
with three modules — an exchange rates list (5 currencies vs EGP with daily change, pull-to-refresh,
loading/error/empty states), a currency detail screen with a 7-day historical line chart and shimmer
loading, and an offline caching layer with last-updated indicator and auto-refresh on reconnect.
Noted the currency-api.pages.dev endpoints, the EGP-base rate inversion, and the evaluation
criteria (architecture, BLoC separation, error handling, testing, git history). No code generated in
this step.
**Action:** Accepted as-is.

---

## Prompt: Build the domain layer (pure Dart, no Flutter/http)

**Full prompt:** Now let's build the domain layer, inside the folders I already made. Pure Dart
only, no Flutter or http:

1) Entity for a currency rate: code, name, rate, daily change (amount + percent), last updated. Make
   it immutable, use Equatable. Note the daily change isn't from the API, we calculate it ourselves
   from today vs yesterday.
2) Entity for a historical point: just date and rate (for the chart).
3) Abstract repository with two methods: getLatestRates(), and getRatesForDate(date) which returns a
   map of currency code to rate for one date (matches how the api responds, all currencies at once).
4) Use case for getting latest rates (no params).
5) Use case for historical rates: takes a currency code and days (default 7), grabs the last N
   dates, calls getRatesForDate for all of them at once, pulls out the one currency from each,
   returns it sorted.

Walk me through your reasoning as you go. Add an entry to AI_USAGE.md too.

**AI response summary:** Created 6 files under `lib/features/exchange_rates/domain/`: entities
   `DailyChange` (amount + percent value object with `isEgpStrengthening`/`isEgpWeakening` helpers
   encoding the inverted EGP sign semantics), `CurrencyRate` (
   code/name/rate/dailyChange/lastUpdated, Equatable, immutable), `HistoricalRatePoint` (date +
   rate); abstract `ExchangeRatesRepository` with `getLatestRates()` and `getRatesForDate(date)`
   returning `Map<String,double>` keyed by lower-case code; `GetLatestRates` use case (callable, no
   params); `GetHistoricalRates` use case (positional code + named `days=7`, generates the last N
   date-only days, `Future.wait`s all `getRatesForDate` calls in parallel, extracts the one currency
   per response, skips days with no value, returns oldest-first). No Flutter/http imports; only
   `equatable`. `dart analyze` on the domain folder: no issues.
   **Action:** Accepted as-is — reviewed the historical date range (starts from today), had a
   concern that the historical endpoint might not have today's date published yet, tested directly
   against the live API and confirmed today's date returns valid data. No fix needed.

---

## Prompt: Build the remote data source (dio + ApiEndpoints, existing exceptions)

**Full prompt:** Now build the remote data source (I have created model so check it). It should use
dio and my ApiEndpoints class from core/network. Two methods:

1) fetchLatestRates() returns the raw json map of rates for today, using ApiEndpoints.latestRates()
2) fetchRatesForDate(date) returns the raw json map for one date, using ApiEndpoints.ratesForDate(
   date)
   Wrap dio calls in try-catch: throw NetworkException for connection/timeout errors, throw
   ServerException for bad status codes or unexpected response shape. Use my existing exception
   classes from core/error/exceptions.dart, don't create new ones.
   Explain your reasoning. Add an entry to AI_USAGE.md.
   **AI response summary:** Created
   `lib/features/exchange_rates/data/datasources/exchange_rates_remote_data_source.dart` with an
   abstract `ExchangeRatesRemoteDataSource` and `ExchangeRatesRemoteDataSourceImpl(Dio)`. Both
   methods return the full decoded response body (`Map<String, dynamic>` —
   `{ "date": ..., "egp": { ... } }`) so the repository can read the `date` for "last updated"; a
   shared private `_getRatesBody(url)` does the fetch. Dio calls wrapped in try/catch:
   `_mapDioException` sends connection/timeout/badCertificate/`unknown`-wrapping-`SocketException` →
   `NetworkException`, and badResponse/cancel/other `unknown` → `ServerException` (status code
   included). After a successful call it also guards `statusCode != 200` (in case of a lenient
   `validateStatus`), non-`Map` payloads, and a missing `egp` object → `ServerException`. Reused
   `NetworkException`/`ServerException` from `core/error/exceptions.dart`; no new exception types.
   Had to add `DioExceptionType.transformTimeout` to the timeout branch for exhaustiveness (dio
   5.11). `dart analyze` on data + core: no issues.
   **Action:** Accepted as-is — reviewed the error mapping logic, confirmed it correctly separates
   network vs server failures and reuses existing exception types as instructed.

---

## Prompt: Build the repository implementation (remote + local + NetworkInfo)

**Full prompt:** Okay now let's build the repository implementation, in
lib/features/exchange_rates/data/repositories/. It implements ExchangeRatesRepository, and should
use the remote data source, local data source, and NetworkInfo (I already built it).
For getLatestRates: check if we're online first. If yes, fetch today's rates and yesterday's rates (
need both to calculate daily change), build the CurrencyRate list for the requested 5 currencies
with inverted rates, save the raw response to cache, return it. If we're offline, just load from
cache instead - if cache is empty too, let that error up. Also if the remote call fails with a
network error even though we thought we were online, fall back to cache too instead of just failing.
For getRatesForDate just call the remote fetch directly, no caching needed, let errors up.
Lastly, I already created tracked_currencies.dart with a list (code + name required ones). Use that
in the repository to know which currencies to build CurrencyRate entities for. Summarize all when
done specially offline part and add an entry to AI_USAGE.md
**AI response summary:** Created
`lib/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart` implementing
`ExchangeRatesRepository` with `(remote, local, networkInfo)` positional constructor (matches
existing impls' style). `getLatestRates`: if `NetworkInfo.isConnected`, `Future.wait`s
`fetchLatestRates()` + `fetchRatesForDate(yesterday)`, caches today's raw body via
`local.cacheRates`, then builds the `CurrencyRate` list; a `NetworkException` mid-fetch is caught
and falls through to the cache; `ServerException` is left to propagate. Offline goes straight to
cache. Cache path builds with `DailyChange.zero()` (no cached yesterday body to diff against) and
maps a corrupt cache to `CacheException`; an empty cache's `CacheException` propagates.
`getRatesForDate` just calls the remote and inverts the `egp` map to `Map<String,double>`, errors
uncaught. Helpers: `_rawRates` (extracts `egp`, drops non-positive/non-numeric), `_dailyChange` (
diffs in inverted "EGP per unit" terms for amount + percent), `_reportedDate` (parses the body's
`date`, defaults to now), `_toEgpPerUnit` (1/raw). Uses `TrackedCurrencies.all` for the currency
set + names. Switched from named to positional constructor to clear a `prefer_initializing_formals`
hint. `dart analyze lib`: no issues.
**Action:** Accepted as-is — reviewed the offline fallback flow, confirmed it correctly
distinguishes network failures from server failures.

---

## Prompt: Build the historical chart widget + shimmer loading version

**Full prompt:** Now analyze what has been done in presentation layer and then let's build the
historical chart widget for the currency detail screen. Use fl_chart for a line chart. Create a
widget called HistoricalRateChart that takes a list of HistoricalRatePoint (date + rate) and renders
a line chart showing the 7-day trend. X-axis should show short date labels, Y-axis shows the rate
value. Make sure the chart doesn't crash or look broken if there are fewer than 7 points (in case
some days were skipped due to missing data). Also create a loading version using the shimmer
package - a placeholder shaped like the chart area shown while data is being fetched. Add an entry
to AI_USAGE.md
**AI response summary:** Analysed the presentation layer: the exchange-rates list feature is fully
wired (bloc/state/event/screen/list content/list item/error view); the currency-detail feature has
`CurrencyDetailBloc` emitting `ChartLoading`/`ChartLoaded(points)`/`ChartError`, but
`CurrencyDetailContent` is still a stub ("Chart coming next") with no `BlocBuilder` — so the new
chart isn't wired in yet (left for a follow-up step, not in this prompt's scope). Created
`lib/features/exchange_rates/presentation/widgets/historical_rate_chart.dart` with two widgets:
`HistoricalRateChart(points)` — fl_chart `LineChart`, x = point index, y = rate; bottom axis shows
`DateFormat('MMM d')` labels (only at integer indices in range), left axis shows adaptive-precision
rate labels (skipping the top/bottom edge values), curved line with `preventCurveOverShooting`,
dots, faint fill, and a touch tooltip (date + rate). Robustness for <7 points: empty → friendly
placeholder; 1 point → `maxX` widened to 1.0 so `minX != maxX`; flat series → Y padding derived from
the value so `yInterval > 0` (guarded with `safeYInterval`); defensive re-sort by date.
`HistoricalRateChartLoading` — `Shimmer.fromColors` over a chart-height block + a row of 7 faux
date-label boxes; shares a `_kChartHeight = 220` constant with the chart so the screen doesn't jump.
Verified fl_chart 1.2.0 API against the installed package source (`SideTitleWidget(meta:)`,
`TitleMeta.min/max`, `LineTouchTooltipData.getTooltipColor`/`tooltipBorderRadius`). `dart analyze`
on the file: no issues.
**Action:** Edited — reviewed and confirmed the chart logic and edge-case handling (
empty/single-point/flat series) were correct, but found the hardcoded colors didn't use the app's
theme system and the file was too large for one widget. Split into chart_axis_label.dart,
chart_bottom_titles.dart, chart_left_titles.dart, historical_rate_chart.dart, and
historical_rate_chart_loading.dart. Moved hardcoded colors into AppColors, added a missing
chartAxisLabel text style to AppTextStyles, added "Date" and "Rate (EGP)" axis titles which weren't
in the original, and replaced SizedBox spacing with Gap for consistency with the rest of the
codebase

---

## Prompt: Wire the chart widgets into the currency detail screen

**Full prompt:** wire them
**AI response summary:** Rewrote
`lib/features/exchange_rates/presentation/widgets/currency_detail_content.dart`. Replaced the stub
with a `SingleChildScrollView` containing: a `_RateSummary` section (private widget) showing
`1 CODE = rate EGP`, the daily change (absolute + percent, colour-coded via
`DailyChange.isEgpStrengthening`/`isEgpWeakening` with an up/down/flat icon), and
`Last updated <DateFormat.yMMMMd()>`; a "Last 7 days" heading; and a
`BlocBuilder<CurrencyDetailBloc, CurrencyDetailState>` mapping
`ChartLoaded → HistoricalRateChart(points:)`, `ChartError → _ChartErrorView` (icon + message + Retry
that re-dispatches `FetchHistoricalRates(rate.code)`), and `CurrencyDetailInitial`/
`ChartLoading → HistoricalRateChartLoading()`. The bloc is already provided by
`CurrencyDetailScreen`. `dart analyze lib`: no issues.
**Action:** Accepted as-is — reviewed the BlocBuilder state mapping (ChartLoading/Initial → shimmer,
ChartLoaded → chart, ChartError → error view with working retry) and the reformatted header (
color-coded change, intl-formatted date). No issues found; confirmed working visually on device.

---

## Prompt: Return ExchangeRatesSnapshot from getLatestRates (cache metadata through to the bloc)

**Full prompt:** I already created ExchangeRatesSnapshot in domain/entities/. Now:

1) Change ExchangeRatesRepository.getLatestRates() to return Future<ExchangeRatesSnapshot> instead
   of Future<List<CurrencyRate>>.
2) Update ExchangeRatesRepositoryImpl: live-fetch success returns isFromCache: false, cachedAt:
   null. Both cache-fallback paths return isFromCache: true with cachedAt from
   local.getLastCachedTime().
3) Update GetLatestRates use case to match the new return type.
4) Update ExchangeRatesBloc so ExchangeRatesLoaded carries isFromCache and cachedAt alongside rates.
   Explain the changes to the repository specifically. Add an entry to AI_USAGE.md.
   **AI response summary:** (1) `ExchangeRatesRepository.getLatestRates()` now returns
   `Future<ExchangeRatesSnapshot>` (import + doc updated). (2) `ExchangeRatesRepositoryImpl`:
   `getLatestRates` and both private helpers now return `Future<ExchangeRatesSnapshot>`.
   `_fetchCacheAndBuildLatest` success wraps `_buildRates(...)` in
   `ExchangeRatesSnapshot(isFromCache: false, cachedAt: null)`; its `on NetworkException` still
   delegates to `_ratesFromCache`. `_ratesFromCache` builds the list (corrupt-cache
   `FormatException` still mapped to `CacheException`, empty-cache `CacheException` from
   `getCachedRates()` still propagates), then returns
   `ExchangeRatesSnapshot(isFromCache: true, cachedAt: await _local.getLastCachedTime())`.
   `_buildRates` unchanged (still returns `List<CurrencyRate>`). Class doc's offline-strategy
   bullets updated to describe the snapshot flags. (3) `GetLatestRates.call()` →
   `Future<ExchangeRatesSnapshot>` (swapped `currency_rate` import for `exchange_rates_snapshot`). (
    4) `ExchangeRatesLoaded` gained `isFromCache` (defaults false) + `cachedAt` named params, both
       added to `props`; `ExchangeRatesBloc._fetchRates` reads `snapshot.rates`/`isFromCache`/
       `cachedAt`
       and passes them through. `exchange_rates_list_content.dart` only reads `state.rates`, so no
       widget change. `dart analyze lib`: no issues.
       **Action:** Accepted as-is — reviewed the repository changes, confirmed cachedAt
       correctly sits outside the FormatException guard, and error propagation (empty/corrupt cache,
       server exceptions) is unchanged from before.

---

## Prompt: Clean up duplication (colour/icon getters, merged error view, styles, dead code)

**Full prompt:** Let's clean up some duplication. A few things:

1) The strengthening/weakening color and icon logic is copy-pasted in both CurrencyRateListItem
   and _RateSummary. Pull that into DailyChange itself (like a color getter and an icon getter) and
   have both widgets just use that instead of their own inline logic.
2) We have got two separate error view widgets (ExchangeRatesErrorView and _ChartErrorView) that do
   basically the same thing with slightly different icons and button styles. Merge them into one
   reusable widget that takes a message, onRetry, and optionally lets you override the icon.
3) _RateSummary has a hardcoded TextStyle(fontSize: 24, bold) instead of using AppTextStyles like
   everywhere else. Add a style for that and use it.
4) Delete failures.dart, nothing uses it.
5) Remove unused text styles and colors
   Walk me through the error view merge specifically since that's the trickiest part. Add an entry
   to AI_USAGE.md.
   **AI response summary:** (1) Added `DailyChange.color` (green/red/grey via `AppColors`) and
   `DailyChange.icon` (`arrow_downward`/`arrow_upward`/`remove`) getters; `daily_change.dart` now
   imports `flutter/material` + `AppColors` (noted the domain→Flutter coupling as a tradeoff for the
   user to weigh). `CurrencyRateListItem` and `_RateSummary` dropped their inline ternary /
   `_changeColor`/`_changeIcon` helpers and use `change.color` / `change.icon`; both lost their
   now-unused `app_colors`/`daily_change` imports. (2) New `error_retry_view.dart` —
   `ErrorRetryView({message, onRetry, icon = Icons.error_outline})`, layout-neutral (
   `Center > Padding > Column(min)`); deleted `exchange_rate_error_view.dart` and the private
   `_ChartErrorView`. Rates list passes `onRetry: () => ...add(ExchangeRatesStarted())` (was
   hardcoded inside the old widget); detail screen wraps it in `SizedBox(height: kChartHeight, ...)`
   with `icon: Icons.show_chart`. Unified on `ElevatedButton` + `AppColors.error` icon +
   `errorMessage` style. (3) Added `AppTextStyles.detailRate` (24/bold); `_RateSummary` uses it. (4)
   Deleted `lib/core/error/failures.dart` (no references). (5) Removed unused
   `AppTextStyles.currencyName` and `AppColors.textPrimary`; everything else still has a referent (
   movement colours now referenced from `DailyChange`). `dart analyze lib` and `dart analyze test`:
   no issues.
   **Action:** Edited — everything was fine except the color/icon getters, which put Flutter
   imports in the domain layer. Moved that logic into a presentation extension instead, so the
   domain stays pure Dart.

---

## Prompt: Unit tests for GetLatestRates and GetHistoricalRates (mocktail)

**Full prompt:** Now write unit tests for GetLatestRates and GetHistoricalRates. Use mocktail to
mock the repository. For GetLatestRates: test it calls the repository once and returns what the
repository gives back, and test exceptions. For GetHistoricalRates: test it calls getRatesForDate
the right number of times for the days parameter, test it extracts the right currency from each
response, test it sorts oldest-first, test it skips a date when the currency is missing from that
response, and test exception if the repository throws. Add an entry to AI_USAGE.md.
**AI response summary:** Added `mocktail: ^1.0.4` to dev_dependencies (was only transitive via
bloc_test) + `flutter pub get`. Created
`test/features/exchange_rates/domain/usecases/get_latest_rates_test.dart` (4 tests: delegates once +
returns the repo's `ExchangeRatesSnapshot` unchanged with `verifyNoMoreInteractions`; rethrows
Network/Server/Cache exceptions via a table-driven group) and `get_historical_rates_test.dart` (7
tests: `getRatesForDate` called `days` times for an explicit `days: 5` and `7` by default, using
`any()` + `registerFallbackValue(DateTime)`; extracts only the requested currency and lowercases
`'USD'`; sorts oldest-first given today-first stubs; skips a day whose response lacks the currency;
rethrows Network/Server exceptions). A `dayAgo(n)` helper mirrors the use case's
`DateTime(y,m,d).subtract(days)` so per-date stubs match by value. Exception tests use
`expect(() => useCase(...), throwsA(same(exception)))` — the closure form, needed because
`GetLatestRates.call` is a non-async arrow that throws synchronously. `flutter test` on the folder:
11/11 pass; `flutter analyze`: clean.
**Action:** Accepted as-is — reviewed both test files, confirmed correct mocking setup, good
edge case coverage (missing currency, exception handling, sort order).
---

## Prompt: Unit tests for ExchangeRatesRepositoryImpl (mocktail)

**Full prompt:** Now test ExchangeRatesRepositoryImpl. Mock the remote data source, local data
source, and NetworkInfo with mocktail. Cover these cases: when online, it fetches today and
yesterday, computes the daily change right, caches the response, and returns isFromCache false. When
offline, it skips the network and just returns cached data with isFromCache true. If the remote call
fails with a network error while online, it should fall back to cache instead of throwing. If it's a
server error, it should not fall back, just throw that error. Empty cache throws CacheException.
Also test getRatesForDate just calls the remote directly, no caching involved. Add an entry to
AI_USAGE.md.
**AI response summary:** Created
`test/features/exchange_rates/data/repositories/exchange_rates_repository_impl_test.dart` — 7 tests,
mocking `ExchangeRatesRemoteDataSource` / `ExchangeRatesLocalDataSource` / `NetworkInfo`. Fixtures
are raw "units per 1 EGP" bodies (usd 0.02→50 EGP today, 0.025→40 yesterday) so assertions land on
round numbers via `closeTo(x, 1e-9)`. Cases: online happy path (verifies `fetchRatesForDate` gets
the calendar-day-before-today via `captureAny()`, `cacheRates(todayBody)` called once,
`isFromCache=false`/`cachedAt=null`, 5 rates, USD change = +10 EGP / +25%, EUR flat); offline (
`isFromCache=true`, `cachedAt` from `getLastCachedTime`, all changes flat since no cached yesterday,
`verifyNever` on all remote calls + `cacheRates`); online + `NetworkException` → falls back to
cache, no rethrow, `cacheRates` never called; online + `ServerException` →
`expectLater(..., throwsA(isA<ServerException>()))` and `getCachedRates` never called; empty cache →
`CacheException` both offline and via the online+NetworkException fallback path; `getRatesForDate` →
hits `fetchRatesForDate` directly, inverts the map, and `verifyNever` on `isConnected`/
`getCachedRates`/`cacheRates`. `setUpAll` registers `DateTime` + `Map<String,dynamic>` fallback
values. `flutter test test/features`: 18/18 pass (incl. the earlier use-case tests);
`flutter analyze`: clean.
**Action:** Accepted as-is — reviewed all 7 tests, confirmed the yesterday-date
verification, the network-vs-server exception distinction, and the offline/cache-empty paths are all
correctly covered.
---

## Prompt: Bloc tests for ExchangeRatesBloc and CurrencyDetailBloc (bloc_test + mocktail)

**Full prompt:** Next ExchangeRatesBloc, test Started goes Loading then Loaded on success, Loading
then Empty when the list is empty, and Loading then Error for each exception type. Also test
Refreshed goes straight to Loaded, no Loading in between. For CurrencyDetailBloc, test the fetch
event goes ChartLoading then ChartLoaded on success, and ChartLoading then ChartError when the list
is empty or when it throws. Add an entry to AI_USAGE.md.
**AI response summary:** Created two `blocTest` files under
`test/features/exchange_rates/presentation/bloc/`. `exchange_rates_bloc_test.dart` (7 tests): mocks
`GetLatestRates` + `NetworkInfo`, stubbing `networkInfo.onConnectivityChanged` with
`Stream<bool>.empty()` in `setUp` so the constructor's reconnect subscription stays silent.
`ExchangeRatesStarted` → `[Loading, Loaded(tRates)]` on a non-empty snapshot, `[Loading, Empty]` on
an empty snapshot, and `[Loading, Error(message)]` table-driven over `NetworkException`/
`ServerException`/`CacheException` (message passed through) plus a generic `Exception` (fixed "
Something went wrong…" copy). `ExchangeRatesRefreshed` → `expect: [Loaded(tRates)]` only, proving no
`Loading` on manual refresh. `currency_detail_bloc_test.dart` (5 tests): mocks `GetHistoricalRates`;
`FetchHistoricalRates('usd')` → `[ChartLoading, ChartLoaded(tPoints)]` on success,
`[ChartLoading, ChartError('No historical data available for this currency.')]` on an empty list,
and `[ChartLoading, ChartError(message)]` table-driven over `NetworkException`/`ServerException` (
passthrough) + generic `Exception` (fixed "Could not load chart data…" copy). Equatable states
compared by value; shared `tRates`/`tPoints` list instances reused between stub and expectation.
`flutter test test/features`: 30/30 pass; `flutter analyze`: clean.

**Action:** Accepted as-is — reviewed both bloc test files, confirmed the connectivity stream stub
correctly isolates the auto-refresh feature from interfering with other tests, and the
Refreshed-emits-no-Loading assertion correctly locks in the intended UX behavior.

---

## Prompt: Set app icon from assets/images and rename the app

**Full prompt:** I added an app icon in assets/images set it and change app name to 'Currecy Echange App'
**AI response summary:** Confirmed the name spelling first ("Currecy Echange" read as typos); user chose "Currency Exchange App". Renamed the display name in Android `android:label` (AndroidManifest.xml), iOS `CFBundleDisplayName` (Info.plist), Flutter `MaterialApp.title` (main.dart), web `<title>` + `apple-mobile-web-app-title` (index.html), web manifest `name`/`short_name`, and macOS `PRODUCT_NAME` (AppInfo.xcconfig); left bundle IDs / package names untouched. For the icon: added `flutter_launcher_icons: ^0.14.3` to dev_dependencies with a config block pointing at `assets/images/app_icon.png` (1254×1254), `flutter pub get`, then `dart run flutter_launcher_icons` — generated Android mipmaps (mdpi→xxxhdpi) and the full iOS AppIcon set (incl. legacy sizes), `remove_alpha_ios: true`. Web/Windows/macOS icon generation reported "requirements failed" and were skipped (source PNG constraints) — not needed for the mobile assessment. `flutter analyze lib` clean; `flutter test test/features` 30/30 pass.
**Action:** Accepted as-is.

---

## Prompt: Fix error handling to degrade gracefully instead of failing outright, and fix small-currency precision

**Full prompt:** Doing a review pass and found three things to fix.

First, in getLatestRates, today's and yesterday's requests are both wrapped in one try that only
catches NetworkException. So if yesterday's call fails with a ServerException, it hides today's
perfectly good rates behind a full error screen — but yesterday's data is only there for computing
the daily change, it shouldn't be able to break the whole thing.

Second, GetHistoricalRates has the same issue across the 7 days it fetches — one bad day and the
whole chart disappears, which also doesn't match what the doc comment already claims it does.

Third, the daily change is shown with a flat 2 decimal places, so JPY's tiny movement renders as "
+0.00" even though it did move.

Fix all three, and add an entry to AI_USAGE.md.

**AI response summary:** Fixed all three. For (1), yesterday's fetch now goes through a helper that
catches any exception and returns null instead of throwing — today's rate stays live either way, and
the app already had a fallback for a missing "yesterday" (shows the change as flat). While building
this, moved both fetch calls inside the try block so they're still fired concurrently, since testing
caught that a synchronous failure could otherwise slip past the safety net entirely. Updated the
class doc comment, which had wrongly claimed server errors are never swallowed here.

For (2), each of the 7 days now fails independently instead of taking down the whole chart. If every
single day fails, that's treated as a real network problem and shown as "no internet" rather than
the misleading "no data for this currency."

For (3), added a small formatting file that handles all the rate/change number formatting in one
place instead of scattered logic. The main rate display stays fixed at 2 decimals to match the
assignment's exact format, but the daily change now scales its precision based on the number's size,
so tiny movements on currencies like JPY actually show up instead of rounding to zero.

Verified against live rates: JPY's change went from "+0.00 (+0.34%)" to "+0.0011 (+0.34%)";
USD/EUR/GBP unchanged. Added 11 new tests covering the fallback behavior and the formatting logic.
All 41 tests pass, dart analyze clean.

**Action:** Accepted as-is — reviewed the fix for the yesterday-fetch and confirmed the self-caught
concurrency bug was handled correctly (moving both fetches inside the try while keeping them
concurrent). Confirmed the historical chart correctly distinguishes "some days failed" from "every
day failed, likely offline." Confirmed the JPY precision fix matches live data and doesn't affect
the headline rate's fixed format from the spec.