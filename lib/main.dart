import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/statement/transaction_data_source.dart';
import 'data/statement/transaction_repo_impl.dart';
import 'domain/statement/fetch_transaction.dart';
import 'l10n/l10n.dart';
import 'presentation/bloc/language/localization_bloc.dart';
import 'presentation/bloc/statement/transaction_bloc.dart';
import 'presentation/bloc/statement/transaction_event.dart';
import 'shared/theme/theme.dart';
import 'shared/router/router_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationBloc>(
          create: (_) => LocalizationBloc(),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            fetchTransactions: FetchTransactions(
              repository: TransactionRepositoryImpl(
                dataSource: TransactionDataSource(),
              ),
            ),
          )..add(LoadTransactions()),
        ),
      ],
      child: const MyAppView(),
    );
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerDelegate: AppRouter.router.routerDelegate,
          routeInformationParser: AppRouter.router.routeInformationParser,
          routeInformationProvider: AppRouter.router.routeInformationProvider,
          locale: state.locale,
          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          title: 'Flutter Demo',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
