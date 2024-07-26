import 'dart:io';

import '../../domain/documents/doc_entity.dart';
import 'doc_datasource.dart';

abstract class UploadPdfRepository {
  Future<UploadPdfEntity> uploadPdf(File file);
}

class UploadPdfRepositoryImpl implements UploadPdfRepository {
  final UploadPdfDataSource dataSource;

  UploadPdfRepositoryImpl(this.dataSource);

  @override
  Future<UploadPdfEntity> uploadPdf(File file) async {
    final model = await dataSource.uploadPdfFile(file);
    return UploadPdfEntity(
      imageId: model.imageId,
      message: model.message,
      status: model.status,
      statusCode: model.statusCode,
    );
  }
}
