import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crop_entity.dart';
import '../repositories/farmer_repository.dart';

/// Use case for getting all crops.
class GetCropsUseCase implements UseCase<List<CropEntity>, GetCropsParams> {
  GetCropsUseCase({required this.repository});
  final FarmerRepository repository;

  @override
  Future<Either<Failure, List<CropEntity>>> call(GetCropsParams params) async {
    return repository.getCrops(params.farmerId);
  }
}

/// Parameters for get crops use case
class GetCropsParams {
  const GetCropsParams({this.farmerId});
  final String? farmerId;
}
