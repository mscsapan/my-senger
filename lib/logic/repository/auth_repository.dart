import 'package:dartz/dartz.dart';

import '../../data/data_provider/local_data_source.dart';
import '../../data/data_provider/remote_data_source.dart';
import '../../data/models/auth/login_state_model.dart';
import '../../data/models/auth/user_response_model.dart';
import '../../presentation/errors/exception.dart';
import '../../presentation/errors/failure.dart';

abstract class AuthRepository {
  Future<Either<dynamic, UserResponseModel>> login(LoginStateModel body);

  Future<Either<Failure, String>> logout(String token);

  Either<Failure, UserResponseModel> getExistingUserInfo();
}

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSources remoteDataSources;
  final LocalDataSources localDataSources;

  AuthRepositoryImpl(
      {required this.remoteDataSources, required this.localDataSources});

  @override
  Future<Either<dynamic, UserResponseModel>> login(LoginStateModel body) async {
    try {
      final result = await remoteDataSources.login(body);
      localDataSources.cacheUserResponse(result);
      //final login = LoginStateModel.fromMap(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on InvalidAuthData catch (e) {
      return Left(InvalidAuthData(e.errors));
    }
  }

  @override
  Either<Failure, UserResponseModel> getExistingUserInfo() {
    try {
      final result = localDataSources.getExistingUserInfo();
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> logout(String token) async {
    try {
      final logout = await remoteDataSources.logout(token);
      localDataSources.clearUserResponse();
      return Right(logout);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }
}
