import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/local_auth_datasource.dart';
import '../../data/datasources/local/local_category_datasource.dart';
import '../../data/datasources/local/local_transaction_datasource.dart';
import '../../data/datasources/local/session_storage.dart';
import '../../data/datasources/remote/remote_auth_datasource.dart';
import '../../data/datasources/remote/direct_news_datasource.dart';
import '../../data/datasources/remote/remote_news_datasource.dart';
import '../../data/datasources/remote/rss_news_datasource.dart';
import '../../data/datasources/remote/remote_transaction_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/categories/delete_category_usecase.dart';
import '../../domain/usecases/categories/save_category_usecase.dart';
import '../../domain/usecases/auth/get_session_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/dashboard/get_summary_usecase.dart';
import '../../domain/usecases/news/get_news_usecase.dart';
import '../../domain/usecases/transactions/delete_transaction_usecase.dart';
import '../../domain/usecases/transactions/get_transactions_usecase.dart';
import '../../domain/usecases/transactions/save_transaction_usecase.dart';
import '../../domain/usecases/transactions/sync_transactions_usecase.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;
  return AppConstants.defaultApiBaseUrl;
});

final sessionStorageProvider = Provider<SessionStorage>((ref) => SessionStorage());

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final apiClientProvider = Provider<ApiClient>((ref) {
  final session = ref.watch(sessionStorageProvider);
  return ApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    getToken: session.getToken,
  );
});

final localAuthProvider = Provider<LocalAuthDataSource>(
  (ref) => LocalAuthDataSource(ref.watch(databaseHelperProvider)),
);

final localTransactionProvider = Provider<LocalTransactionDataSource>(
  (ref) => LocalTransactionDataSource(ref.watch(databaseHelperProvider)),
);

final localCategoryProvider = Provider<LocalCategoryDataSource>(
  (ref) => LocalCategoryDataSource(ref.watch(databaseHelperProvider)),
);

final remoteAuthProvider = Provider<RemoteAuthDataSource>(
  (ref) => RemoteAuthDataSource(ref.watch(apiClientProvider)),
);

final remoteTransactionProvider = Provider<RemoteTransactionDataSource>(
  (ref) => RemoteTransactionDataSource(ref.watch(apiClientProvider)),
);

final remoteNewsProvider = Provider<RemoteNewsDataSource>(
  (ref) => RemoteNewsDataSource(ref.watch(apiClientProvider)),
);

final directNewsProvider = Provider<DirectNewsDataSource>(
  (ref) => DirectNewsDataSource(),
);

final rssNewsProvider = Provider<RssNewsDataSource>(
  (ref) => RssNewsDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    local: ref.watch(localAuthProvider),
    remote: ref.watch(remoteAuthProvider),
    session: ref.watch(sessionStorageProvider),
  ),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    local: ref.watch(localTransactionProvider),
    remote: ref.watch(remoteTransactionProvider),
    session: ref.watch(sessionStorageProvider),
  ),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(
    local: ref.watch(localCategoryProvider),
    session: ref.watch(sessionStorageProvider),
  ),
);

final categoriesStreamProvider = StreamProvider<List<CategoryEntity>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchCategories(),
);

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepositoryImpl(
    ref.watch(remoteNewsProvider),
    ref.watch(directNewsProvider),
    ref.watch(rssNewsProvider),
  ),
);

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final getSessionUseCaseProvider = Provider((ref) => GetSessionUseCase(ref.watch(authRepositoryProvider)));
final getTransactionsUseCaseProvider = Provider((ref) => GetTransactionsUseCase(ref.watch(transactionRepositoryProvider)));
final saveTransactionUseCaseProvider = Provider((ref) => SaveTransactionUseCase(ref.watch(transactionRepositoryProvider)));
final deleteTransactionUseCaseProvider = Provider((ref) => DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider)));
final syncTransactionsUseCaseProvider = Provider((ref) => SyncTransactionsUseCase(ref.watch(transactionRepositoryProvider)));
final getSummaryUseCaseProvider = Provider((ref) => GetSummaryUseCase(ref.watch(transactionRepositoryProvider)));
final getNewsUseCaseProvider = Provider((ref) => GetNewsUseCase(ref.watch(newsRepositoryProvider)));
final saveCategoryUseCaseProvider =
    Provider((ref) => SaveCategoryUseCase(ref.watch(categoryRepositoryProvider)));
final deleteCategoryUseCaseProvider =
    Provider((ref) => DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider)));

final transactionsStreamProvider = StreamProvider((ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions();
});

final summaryProvider = FutureProvider<dynamic>((ref) async {
  ref.watch(transactionsStreamProvider);
  return ref.watch(getSummaryUseCaseProvider).call();
});
