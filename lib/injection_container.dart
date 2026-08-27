import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import core
import 'core/services/settings_service.dart';
import 'core/services/google_sheets_service.dart';
import 'core/services/sync_service.dart';

// Import skema model lu buat Isar
import 'features/transaction/data/models/transaction_model.dart';
import 'features/category/data/models/category_model.dart';

// Import bloc
import 'features/transaction/presentation/bloc/transaction_bloc.dart';

// Import Data Sources
import 'features/transaction/data/datasources/transaction_local_datasource.dart';
import 'features/category/data/datasources/category_local_datasource.dart';

// Import Repositories
import 'features/transaction/domain/repositories/i_transaction_repository.dart';
import 'features/transaction/data/repositories/transaction_repository_impl.dart';
import 'features/category/domain/repositories/i_category_repository.dart';
import 'features/category/data/repositories/category_repository_impl.dart';

// Import Use Cases
import 'features/transaction/domain/usecases/get_recent_transactions.dart';
import 'features/transaction/domain/usecases/save_transaction.dart';
import 'features/transaction/domain/usecases/update_transaction.dart';
import 'features/transaction/domain/usecases/delete_transaction.dart';
import 'features/transaction/domain/usecases/parse_voice_input.dart';
import 'features/transaction/domain/usecases/receipt_scanner_usecase.dart';
import 'features/category/domain/usecases/get_categories.dart';
import 'features/category/domain/usecases/save_category.dart';
import 'features/category/domain/usecases/delete_category.dart';
import 'features/category/domain/usecases/reorder_categories.dart';

// Import Bloc
import 'features/transaction/presentation/bloc/history/history_bloc.dart';
import 'features/transaction/presentation/bloc/scanner/scanner_bloc.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // ==========================================================
  // 1. EXTERNAL LIBRARIES & CORE
  // ==========================================================
  
  // Buka koneksi Isar langsung di dalam DI Container
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TransactionModelSchema, CategoryModelSchema],
    directory: dir.path,
  );
  
  // Daftarkan Isar ke memori GetIt
  sl.registerLazySingleton<Isar>(() => isar);

  // Daftarkan SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<SettingsService>(() => SettingsService(sl()));
  
  // Register Cloud & Sync Services
  sl.registerLazySingleton<GoogleSheetsService>(() => GoogleSheetsService());
  sl.registerLazySingleton<SyncService>(() => SyncService(sl(), sl()));

  // ==========================================================
  // 2. DATA SOURCES
  // ==========================================================
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(sl()),
  );

  // ==========================================================
  // 3. REPOSITORY
  // ==========================================================
  sl.registerLazySingleton<ITransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ICategoryRepository>(
    () => CategoryRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // ==========================================================
  // 4. USE CASES
  // ==========================================================
  sl.registerLazySingleton(() => SaveTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => GetRecentTransactions(sl()));
  sl.registerLazySingleton(() => ParseVoiceInput());
  sl.registerLazySingleton(() => ReceiptScannerUseCase());
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => SaveCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => ReorderCategoriesUseCase(sl()));

  // ==========================================================
  // 5. PRESENTATION (BLoC / Controller)
  // ==========================================================
  sl.registerFactory(
    () => TransactionBloc(
      saveTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
      getRecentTransactions: sl(),
      parseVoiceInput: sl(),
      getCategories: sl(),
      syncService: sl(),
    ),
  );
  sl.registerFactory(() => ScannerBloc(sl()));
  sl.registerFactory(() => HistoryBloc(sl()));
  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl(),
      saveCategory: sl(),
      deleteCategory: sl(),
      reorderCategories: sl(),
    ),
  );
  sl.registerFactory(() => SettingsCubit(sl()));

  // ==========================================================
  // 6. SEED DEFAULT CATEGORIES
  // ==========================================================
  final categoryRepo = sl<ICategoryRepository>();
  await categoryRepo.seedDefaultCategories();
}