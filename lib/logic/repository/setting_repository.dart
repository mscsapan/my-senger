import 'package:dartz/dartz.dart';

import '../../data/data_provider/local_data_source.dart';
import '../../data/data_provider/remote_data_source.dart';
import '../../data/models/setting/website_setup_model.dart';
import '../../presentation/errors/exception.dart';
import '../../presentation/errors/failure.dart';

abstract class SettingRepository {
  Future<Either<Failure, WebsiteSetupModel>> getSetting();

  Either<Failure, bool> checkOnBoarding();

  Future<Either<Failure, bool>> cachedOnBoarding();
}

class SettingRepositoryImpl implements SettingRepository {
  final LocalDataSources localDataSources;
  final RemoteDataSources remoteDataSources;

  SettingRepositoryImpl(
      {required this.remoteDataSources, required this.localDataSources});

  @override
  Future<Either<Failure, WebsiteSetupModel>> getSetting() async {
    try {
      final result = await remoteDataSources.getSetting();
      final web = WebsiteSetupModel.fromMap(result);
      return Right(web);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, bool>> cachedOnBoarding() async {
    try {
      final result = await localDataSources.cachedOnBoarding();
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Either<Failure, bool> checkOnBoarding() {
    try {
      return Right(localDataSources.checkOnBoarding());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
