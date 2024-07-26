import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'doc_model.dart';

abstract class UploadPdfDataSource {
  Future<UploadPdfModel> uploadPdfFile(File file);
}

class UploadPdfDataSourceImpl implements UploadPdfDataSource {
  final http.Client client;

  UploadPdfDataSourceImpl(this.client);

  @override
  Future<UploadPdfModel> uploadPdfFile(File file) async {
    final uri = Uri.parse('https://api-innovitegra.online/uploads/document');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('docs_file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return UploadPdfModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to upload PDF');
    }
  }
}
