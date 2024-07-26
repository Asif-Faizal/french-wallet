import 'package:equatable/equatable.dart';

import '../../../domain/documents/doc_entity.dart';

abstract class UploadPdfState extends Equatable {
  @override
  List<Object> get props => [];
}

class UploadPdfInitial extends UploadPdfState {}

class UploadPdfInProgress extends UploadPdfState {}

class UploadPdfSuccess extends UploadPdfState {
  final UploadPdfEntity uploadPdfEntity;

  UploadPdfSuccess(this.uploadPdfEntity);

  @override
  List<Object> get props => [uploadPdfEntity];
}

class UploadPdfFailure extends UploadPdfState {
  final String error;

  UploadPdfFailure(this.error);

  @override
  List<Object> get props => [error];
}
