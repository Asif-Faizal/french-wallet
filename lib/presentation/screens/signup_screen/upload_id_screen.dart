import 'package:ewallet2/presentation/bloc/image/image_bloc.dart';
import 'package:ewallet2/presentation/bloc/image/image_state.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

import '../../bloc/image/image_event.dart';

class UploadIdScreen extends StatefulWidget {
  const UploadIdScreen({super.key});

  @override
  State<UploadIdScreen> createState() => _UploadIdScreenState();
}

class _UploadIdScreenState extends State<UploadIdScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _frontPhoto;
  XFile? _backPhoto;

  bool _isButtonEnabled = false;

  Future<void> _pickImage(bool isFront) async {
    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
    if (pickedImage != null) {
      setState(() {
        if (isFront) {
          _frontPhoto = pickedImage;
        } else {
          _backPhoto = pickedImage;
        }
      });
      context.read<UploadImageBloc>().add(TakeImageEvent(image: pickedImage));
    }
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 40),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );
  }

  void _hideProgressDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return BlocConsumer<UploadImageBloc, UploadImageState>(
      listener: (context, state) {
        if (state is UploadImageSuccess) {
          print('Response: ${state.imageModel.toJson()}');
          print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&${state.imageModel.status}');
          if (state.imageModel.status == 'Success') {
            setState(() {
              _isButtonEnabled = _frontPhoto != null && _backPhoto != null;
            });
          }
          _hideProgressDialog(context);
        } else if (state is UploadImageFailure) {
          print('Failed to upload image: ${state.error}');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error)));
          _hideProgressDialog(context);
        } else if (state is UploadImageInProgress) {
          _showProgressDialog(context);
        }
      },
      builder: (context, state) {
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
                                        image:
                                            FileImage(File(_frontPhoto!.path)),
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
                                        image:
                                            FileImage(File(_backPhoto!.path)),
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
                    'The ID card picture will be solely used for the KYC purpose. The data will be secure in our system with 128-bit encryption.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: NormalButton(
              size: size,
              title: AppLocalizations.of(context)!.continue_text,
              onPressed: _isButtonEnabled
                  ? () {
                      GoRouter.of(context).pushNamed(AppRouteConst.selfieRoute);
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}
