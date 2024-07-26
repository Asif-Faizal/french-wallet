import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../data/image/image_datasource.dart';
import '../../../data/image/image_repo.dart';
import '../../../domain/image/upload_image.dart';
import '../../../shared/config/api_config.dart';
import '../../bloc/image/image_bloc.dart';
import '../../bloc/image/image_event.dart';
import '../../bloc/image/image_state.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class TakeSelfieScreen extends StatelessWidget {
  const TakeSelfieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadImageBloc(
        uploadImageUseCase: UploadImageUseCase(
          repository: ImageRepository(
            dataSource: ImageDataSource(uploadUrl: Config.upload_image),
          ),
        ),
      ),
      child: TakeSelfieScreenBody(),
    );
  }
}

class TakeSelfieScreenBody extends StatefulWidget {
  @override
  State<TakeSelfieScreenBody> createState() => _TakeSelfieScreenBodyState();
}

class _TakeSelfieScreenBodyState extends State<TakeSelfieScreenBody> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return BlocConsumer<UploadImageBloc, UploadImageState>(
      listener: (context, state) {
        if (state is UploadImageSuccess) {
          print('Response: ${state.imageModel.toJson()}');
          GoRouter.of(context).pushNamed(AppRouteConst.personalDetailsRoute);
        } else if (state is UploadImageFailure) {
          print('Failed to upload image: ${state.error}');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error)));
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
                    onPressed:
                        _isButtonEnabled && state is! UploadImageInProgress
                            ? () {
                                context
                                    .read<UploadImageBloc>()
                                    .add(TakeImageEvent(image: _selfieImage!));
                              }
                            : null,
                  ),
                  SizedBox(height: size.height / 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
