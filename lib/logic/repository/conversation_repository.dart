import 'package:dartz/dartz.dart';

import '../../data/data_provider/local_data_source.dart';
import '../../data/data_provider/remote_data_source.dart';
import '../../data/models/setting/website_setup_model.dart';
import '../../presentation/errors/exception.dart';
import '../../presentation/errors/failure.dart';

abstract class ConversationRepository {
  Future<Either<Failure, WebsiteSetupModel>> getSetting();

}

class ConversationRepositoryImpl implements ConversationRepository {
  final RemoteDataSources remoteDataSources;

  ConversationRepositoryImpl({required this.remoteDataSources});

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
}
