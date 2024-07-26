import 'package:bloc/bloc.dart';

import '../../../domain/image/upload_image.dart';
import 'image_event.dart';
import 'image_state.dart';

class UploadImageBloc extends Bloc<UploadImageEvent, UploadImageState> {
  final UploadImageUseCase uploadImageUseCase;

  UploadImageBloc({required this.uploadImageUseCase})
      : super(UploadImageInitial()) {
    on<TakeImageEvent>(_onTakeImageEvent);
  }

  Future<void> _onTakeImageEvent(
      TakeImageEvent event, Emitter<UploadImageState> emit) async {
    emit(UploadImageInProgress());
    try {
      final imageModel = await uploadImageUseCase.execute(event.image);
      emit(UploadImageSuccess(imageModel: imageModel));
    } catch (error) {
      emit(UploadImageFailure(error: error.toString()));
    }
  }
}
