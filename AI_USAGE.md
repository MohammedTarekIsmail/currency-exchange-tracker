# AI Usage Log

This document tracks how AI was used throughout this project, end to end.
Each entry includes: the prompt, what the AI returned, and whether it was
accepted, edited, or rejected — and why.

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
   Walk me through your reasoning as you go. Add an entry to AI_USAGE.md too
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