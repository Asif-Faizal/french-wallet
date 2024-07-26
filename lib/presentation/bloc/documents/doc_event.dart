import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class UploadPdfEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UploadPdfFileEvent extends UploadPdfEvent {
  final PlatformFile pdfFile;

  UploadPdfFileEvent(this.pdfFile);

  @override
  List<Object> get props => [pdfFile];
}
