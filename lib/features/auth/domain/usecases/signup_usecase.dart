import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration.
class SignupUseCase implements UseCase<UserEntity, SignupParams> {
  SignupUseCase({required this.repository});
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignupParams params) async {
    // Validate inputs
    if (params.email.isEmpty) {
      return const Left(ValidationFailure(message: 'Email is required'));
    }
    if (params.password.isEmpty) {
      return const Left(ValidationFailure(message: 'Password is required'));
    }
    if (params.password.length < 6) {
      return const Left(
        ValidationFailure(
          message: 'Password must be at least 6 characters',
        ),
      );
    }
    if (params.confirmPassword != null &&
        params.password != params.confirmPassword) {
      return const Left(ValidationFailure(message: 'Passwords do not match'));
    }

    return repository.signUpWithEmail(
      email: params.email.trim(),
      password: params.password,
      displayName: params.displayName?.trim(),
    );
  }
}

/// Parameters for signup use case
class SignupParams {
  const SignupParams({
    required this.email,
    required this.password,
    this.confirmPassword,
    this.displayName,
  });
  final String email;
  final String password;
  final String? confirmPassword;
  final String? displayName;
}
