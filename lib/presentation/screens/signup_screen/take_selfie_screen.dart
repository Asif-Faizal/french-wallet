import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class TakeSelfieScreen extends StatefulWidget {
  const TakeSelfieScreen({super.key});

  @override
  State<TakeSelfieScreen> createState() => _TakeSelfieScreenState();
}

class _TakeSelfieScreenState extends State<TakeSelfieScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selfieImage;

  bool get _isButtonEnabled => _selfieImage != null;
  Future<void> _takeSelfie() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selfieImage = pickedImage;
      });
      await _uploadImage(_selfieImage!);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    final uri = Uri.parse(Config.upload_image);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile(
          'image_file',
          File(image.path).readAsBytes().asStream(),
          File(image.path).lengthSync(),
          filename: path.basename(image.path),
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Response data: $responseBody');
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const NormalAppBar(text: ''),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height / 60,
              ),
              Text(
                'Take Selfie',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: size.height * 0.05),
              Center(
                child: GestureDetector(
                  onTap: _takeSelfie,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 1.0,
                      ),
                      image: _selfieImage != null
                          ? DecorationImage(
                              image: FileImage(File(_selfieImage!.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selfieImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: theme.colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Your selfie will be used for verification purposes only. We ensure your data security with 128-bit encryption.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height / 30),
              NormalButton(
                size: size,
                title: AppLocalizations.of(context)!.continue_text,
                onPressed: _isButtonEnabled
                    ? () {
                        GoRouter.of(context)
                            .pushNamed(AppRouteConst.personalDetailsRoute);
                      }
                    : null,
              ),
              SizedBox(height: size.height / 30),
            ],
          ),
        ),
      ),
    );
  }
}
