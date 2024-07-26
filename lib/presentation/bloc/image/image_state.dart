import 'package:equatable/equatable.dart';
import '../../../data/image/image_model.dart';

abstract class UploadImageState extends Equatable {
  const UploadImageState();

  @override
  List<Object?> get props => [];
}

class UploadImageInitial extends UploadImageState {}

class UploadImageInProgress extends UploadImageState {}

class UploadImageSuccess extends UploadImageState {
  final ImageModel imageModel;

  const UploadImageSuccess({required this.imageModel});

  @override
  List<Object?> get props => [imageModel];
}

class UploadImageFailure extends UploadImageState {
  final String error;

  const UploadImageFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
