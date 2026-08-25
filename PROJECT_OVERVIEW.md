# Coin Log

A personal finance / expense-tracking mobile app built with Flutter. Coin Log lets a
user record income, expense, and transfer transactions across multiple accounts, track
per-category budgets, and view spending summaries (charts) by day/month/year.

## Tech Stack

- **Framework:** Flutter (Dart SDK `^3.6.0`)
- **State management:** `provider`
- **Local storage:** `sqflite` (SQLite) via a hand-rolled data access layer — no ORM
- **Charts:** `fl_chart`, `pie_chart`
- **Other notable packages:** `file_picker` & `path_provider` (DB export/import),
  `permission_handler` (storage permission for backup), `month_picker_dialog`,
  `math_expressions` (calculator-style amount input), `fluttertoast`, `reorderables`
  (drag-to-reorder lists), `intl` (date/number formatting)
- **Platforms:** Android, iOS, Windows, Linux, macOS, Web (standard Flutter multi-platform
  scaffolding is present, though the app is primarily mobile-oriented)

## Architecture

The codebase follows a simple layered structure (not a specific framework like BLoC/Riverpod):

```
lib/
├── main.dart                # App entry point, theme (dark ColorScheme), routes
├── models/                  # Plain Dart domain entities, map <-> SQLite rows
├── form_models/             # Lightweight models bound to input forms/widgets
├── services/                # Data-access layer (SQL queries) + business logic
├── utils/                   # Cross-cutting helpers (balance recalculation, date fmt, calculator)
├── constants/                # Static lookup maps (icons, month/week names)
├── router/                  # Custom PageRouteBuilder wrapper (slide transition)
├── permission_handler/      # Storage permission helper for DB export
├── shared_widgets/          # Reusable UI components (dialogs, pickers, themed inputs)
└── views/                   # Screens, organized by feature
    ├── app_frame/            # Bottom-nav shell: Records, Summary, Accounts, Settings
    ├── settings/              # Category, account, budget CRUD screens
    └── sample/                # Boilerplate/example widgets
```

### Data flow pattern

Each domain entity (`Record_`, `Account`, `Budget`, `TransactionCategory`,
`BudgetTransaction`, `AccountLog`) implements `BaseModel<T>`, giving it:
- `toMap()` / `fromMap()` — SQLite row (de)serialization
- `toFormModel()` — conversion to a `form_models/*FormModel` used by edit screens

Each entity has a matching `*Service` class (e.g. `RecordService`, `AccountService`)
that wraps `sqflite` queries — CRUD plus reporting queries (sums/grouping by
category, year, month, day) used to power the Summary charts.

### Views (`BaseView`)

Screens implement a `BaseView` interface exposing a `className`, used by
`RouterUtils.createRoute()` to build routes with a bottom-to-top slide transition
and named `RouteSettings` (for tracking/back-navigation logic).

`AppFrame` is the root shell: a `Scaffold` with a `BottomNavigationBar` (Records,
Summary, Accounts, Settings) and a center floating "+" action button that opens
`RecordDetails` to add a new transaction.

## Database Schema (SQLite, `coin_log.db`)

| Table | Purpose |
|---|---|
| `CL_TRANSACTION_CATEGORY` | Expense/Income categories (name, icon, type, sequence, closed flag) |
| `CL_ACCOUNT` | Money accounts, e.g. Bank/E-Wallet/Cash (balance, default flag, closed flag) |
| `CL_RECORD` | Transactions: Expense, Income, or Transfer (amount, date, category, source/destination account) |
| `CL_ACCOUNT_LOG` | Audit trail of every balance change (insert/update/delete) per account per record |
| `CL_BUDGET` | Per-category budget caps (Monthly or Yearly period) |
| `CL_BUDGET_TRANSACTION` | Ledger entries tracked against a budget |

The DB is seeded on first run with default categories (Breakfast, Lunch, Dinner,
Salary, Other) and accounts (Bank, E-Wallet, Cash). Schema is currently at
**version 4**, with `onUpgrade` migration logic in `DatabaseService`.

### Balance integrity (`utils/BalanceManager.dart`)

Central to the app: whenever a transaction/transfer `Record_` is inserted, updated,
or deleted, `BalanceManager` recalculates the affected account balance(s) and writes
an entry to `CL_ACCOUNT_LOG` capturing old/new balance — this is what
`AccountLogDetails` view surfaces as a per-account transaction/audit history.

## Key Features (inferred from views)

- **Records** — list/add/edit/delete expense, income, and transfer transactions;
  calendar and day-view browsing (`record_calendar.dart`, `record_day_view.dart`)
- **Summary** — charts (pie/bar via `fl_chart`/`pie_chart`) of spending by category,
  broken down by day/month/year
- **Accounts** — manage multiple accounts and view running balances
  (`accounts_balance.dart`, `budget_balance.dart`), plus an audit log per account
- **Budgets** — set monthly/yearly caps per category and track transactions against them
- **Settings** — manage transaction categories, accounts, budgets, and data
  import/export (backup/restore the SQLite DB file to device storage)

## Running the project

```bash
flutter pub get
flutter run
```

Standard Flutter tooling applies (`flutter test`, `flutter build apk`, etc.).
`analysis_options.yaml` uses `flutter_lints` for static analysis.
