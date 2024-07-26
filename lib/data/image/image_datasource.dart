import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageDataSource {
  final String uploadUrl;

  ImageDataSource({required this.uploadUrl});

  Future<http.Response> uploadImage(XFile image) async {
    final uri = Uri.parse(uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile(
          'image_file',
          await image.readAsBytes().asStream(),
          await image.length(),
          filename: image.name,
        ),
      );
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    return responseBody;
  }
}
