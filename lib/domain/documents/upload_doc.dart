import 'dart:io';

import '../../data/documents/doc_repo.dart';
import 'doc_entity.dart';

class UploadPdfUseCase {
  final UploadPdfRepository repository;

  UploadPdfUseCase(this.repository);

  Future<UploadPdfEntity> call(File file) async {
    return await repository.uploadPdf(file);
  }
}
