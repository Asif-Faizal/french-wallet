import 'package:image_picker/image_picker.dart';
import '../../data/image/image_model.dart';
import '../../data/image/image_repo.dart';

class UploadImageUseCase {
  final ImageRepository repository;

  UploadImageUseCase({required this.repository});

  Future<ImageModel> execute(XFile image) async {
    return await repository.uploadImage(image);
  }
}
