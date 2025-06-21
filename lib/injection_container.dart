import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sotfbee/features/monitoring/data/datasources/apiary_remote_data_source.dart';
import 'package:sotfbee/features/monitoring/data/datasources/apiary_remote_data_source_impl.dart';
import 'package:sotfbee/features/monitoring/data/repositories/apiary_repository_impl.dart';
import 'package:sotfbee/features/monitoring/domain/repositories/apiary_repository.dart';
import 'package:sotfbee/features/monitoring/domain/usecases/get_user_apiaries.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Dio Client
  getIt.registerSingleton<Dio>(
    Dio()
      ..options = BaseOptions(
        baseUrl: 'https://softbee-back-end.onrender.com/api', // Reemplaza con tu URL base
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      )
      ..interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          error: true,
        ),
      ),
  );

  // Apiary Dependencies
  getIt.registerLazySingleton<ApiaryRemoteDataSource>(
    () => ApiaryRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<ApiaryRepository>(
    () =>
        ApiaryRepositoryImpl(remoteDataSource: getIt<ApiaryRemoteDataSource>()),
  );

  getIt.registerLazySingleton(() => GetUserApiaries(getIt<ApiaryRepository>()));

  // ... otras dependencias que ya tengas ...
}
