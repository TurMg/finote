import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';
import 'features/transaction/presentation/bloc/transaction_event.dart';
import 'features/transaction/presentation/bloc/history/history_bloc.dart';
import 'features/transaction/presentation/bloc/history/history_event.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/category/presentation/bloc/category_event.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  // Pastikan dependency injection lu jalan sebelum UI dirender
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<TransactionBloc>()..add(FetchRecentTransactions())),
        BlocProvider(create: (_) => di.sl<HistoryBloc>()..add(LoadHistory())),
        BlocProvider(create: (_) => di.sl<CategoryBloc>()..add(LoadAllCategories())),
        BlocProvider(create: (_) => di.sl<SettingsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Finote',
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
