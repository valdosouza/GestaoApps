import 'package:bloc/bloc.dart';
import '../../domain/usecase/check_permission.dart';
import 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit({required this.checkPermission})
      : super(const PermissionState());

  final CheckPermission checkPermission;

  Future<void> check({
    required String menu,
    required String kind,
    required String situation,
  }) async {
    emit(const PermissionState(status: PermissionStatus.loading));
    final result = await checkPermission(
      menu: menu,
      kind: kind,
      situation: situation,
    );
    result.fold(
      (failure) => emit(PermissionState(
        status: PermissionStatus.error,
        errorMessage: failure.message,
      )),
      (permission) => emit(PermissionState(
        status:
            permission.result ? PermissionStatus.granted : PermissionStatus.denied,
      )),
    );
  }
}
