import 'package:dartz/dartz.dart';

import '../../data/data_provider/local_data_source.dart';
import '../../data/data_provider/remote_data_source.dart';
import '../../data/models/setting/website_setup_model.dart';
import '../../presentation/errors/exception.dart';
import '../../presentation/errors/failure.dart';

abstract class ConversationRepository {
  Future<Either<Failure, String?>> sendChatNotification(Map ? body,String token);

}

class ConversationRepositoryImpl implements ConversationRepository {
  final RemoteDataSources remoteDataSources;

  ConversationRepositoryImpl({required this.remoteDataSources});

  @override
  Future<Either<Failure, String?>> sendChatNotification(Map ? body,String token) async {
    try {
      final result = await remoteDataSources.sendChatNotification(body,token);
      final web = result['name'] ?? '';
      return Right(web);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }
}
