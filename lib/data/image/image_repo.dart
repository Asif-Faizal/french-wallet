import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'image_datasource.dart';
import 'image_model.dart';

class ImageRepository {
  final ImageDataSource dataSource;

  ImageRepository({required this.dataSource});

  Future<ImageModel> uploadImage(XFile image) async {
    final response = await dataSource.uploadImage(image);
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return ImageModel.fromJson(jsonResponse);
  }
}
