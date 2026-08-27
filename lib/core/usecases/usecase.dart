// core/usecases/usecase.dart

// Interface baku untuk semua UseCase
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}