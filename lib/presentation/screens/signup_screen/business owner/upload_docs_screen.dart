import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/router/router_const.dart';
import '../../../bloc/documents/doc_bloc.dart';
import '../../../bloc/documents/doc_event.dart';
import '../../../bloc/documents/doc_state.dart';
import '../../../widgets/shared/normal_appbar.dart';

class UploadPdfScreen extends StatefulWidget {
  const UploadPdfScreen({super.key});

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  PlatformFile? _pdfFile1;
  PlatformFile? _pdfFile2;

  Future<void> _pickPdf(int fileNumber) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        if (fileNumber == 1) {
          _pdfFile1 = result.files.first;
        } else if (fileNumber == 2) {
          _pdfFile2 = result.files.first;
        }
      });

      if (_pdfFile1 != null && _pdfFile2 != null) {
        context.read<UploadPdfBloc>().add(UploadPdfFileEvent(_pdfFile1!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<UploadPdfBloc, UploadPdfState>(
      listener: (context, state) async {
        if (state is UploadPdfSuccess) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('docId', state.uploadPdfEntity.imageId);
          print('Response: ${state.uploadPdfEntity}');
          if (state.uploadPdfEntity.status == 'Success') {
            print(state.uploadPdfEntity.imageId);
            GoRouter.of(context)
                .pushNamed(AppRouteConst.politicallyExposedRoute);
          }
        } else if (state is UploadPdfFailure) {
          print('Failed to upload PDF: ${state.error}');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const NormalAppBar(text: ''),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: InkWell(
                    onTap: () => _pickPdf(1),
                    child: Card(
                      child: Container(
                        width: size.width / 1.5,
                        height: size.height / 6,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: size.height / 20,
                            ),
                            SizedBox(height: size.height / 40),
                            Text(
                              _pdfFile1 != null
                                  ? _pdfFile1!.name
                                  : 'Upload PDF 1',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height / 20),
                InkWell(
                  onTap: () => _pickPdf(2),
                  child: Card(
                    child: Container(
                      width: size.width / 1.5,
                      height: size.height / 6,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: size.height / 20,
                          ),
                          SizedBox(height: size.height / 40),
                          Text(
                            _pdfFile2 != null
                                ? _pdfFile2!.name
                                : 'Upload PDF 2',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(15),
            child: NormalButton(
              size: size,
              title: 'Continue',
              onPressed: (_pdfFile1 != null && _pdfFile2 != null)
                  ? () {
                      context
                          .read<UploadPdfBloc>()
                          .add(UploadPdfFileEvent(_pdfFile1!));
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}
