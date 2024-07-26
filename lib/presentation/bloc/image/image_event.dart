import 'package:image_picker/image_picker.dart';

abstract class UploadImageEvent {}

class TakeImageEvent extends UploadImageEvent {
  final XFile image;

  TakeImageEvent({required this.image});
}
