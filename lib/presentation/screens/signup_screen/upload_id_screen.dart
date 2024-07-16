import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

class UploadIdScreen extends StatefulWidget {
  const UploadIdScreen({super.key});

  @override
  State<UploadIdScreen> createState() => _UploadIdScreenState();
}

class _UploadIdScreenState extends State<UploadIdScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _frontPhoto;
  XFile? _backPhoto;

  bool get _isButtonEnabled => _frontPhoto != null && _backPhoto != null;

  Future<void> _pickImage(bool isFront) async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        if (isFront) {
          _frontPhoto = pickedImage;
        } else {
          _backPhoto = pickedImage;
        }
      });
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
                'Upload Photo of ID',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: size.height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        _frontPhoto != null
                            ? 'Change front Image'
                            : 'Add front Image',
                        style: theme.textTheme.bodySmall,
                      ),
                      SizedBox(
                        height: size.height / 80,
                      ),
                      GestureDetector(
                        onTap: () => _pickImage(true),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: theme.colorScheme.secondary,
                              width: 0.5,
                            ),
                            image: _frontPhoto != null
                                ? DecorationImage(
                                    image: FileImage(File(_frontPhoto!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _frontPhoto == null
                              ? Icon(
                                  Icons.add_a_photo,
                                  size: 20,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _backPhoto != null
                            ? 'Change back Image'
                            : 'Add back Image',
                        style: theme.textTheme.bodySmall,
                      ),
                      SizedBox(
                        height: size.height / 80,
                      ),
                      GestureDetector(
                        onTap: () => _pickImage(false),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: theme.colorScheme.secondary,
                              width: 0.5,
                            ),
                            image: _backPhoto != null
                                ? DecorationImage(
                                    image: FileImage(File(_backPhoto!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _backPhoto == null
                              ? Icon(
                                  Icons.add_a_photo,
                                  size: 20,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                  'The ID card picture will be solely used for the KYC purpose. The data will be secure in our system  with 128 KB encryption.',
                  style: theme.textTheme.bodySmall),
              SizedBox(height: size.height / 30),
              NormalButton(
                size: size,
                title: AppLocalizations.of(context)!.continue_text,
                onPressed: _isButtonEnabled
                    ? () {
                        // Handle button press
                      }
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        GoRouter.of(context)
                            .pushNamed(AppRouteConst.selfieRoute);
                      },
                      child: Text('Enter details manually',
                          style: TextStyle(color: Colors.black, fontSize: 14)))
                ],
              ),
              SizedBox(height: size.height / 30),
            ],
          ),
        ),
      ),
    );
  }
}
