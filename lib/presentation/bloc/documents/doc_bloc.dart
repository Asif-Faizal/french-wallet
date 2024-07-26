import 'package:bloc/bloc.dart';
import 'package:ewallet2/presentation/bloc/documents/doc_state.dart';
import '../../../domain/documents/upload_doc.dart';
import 'doc_event.dart';
import 'dart:io';

class UploadPdfBloc extends Bloc<UploadPdfEvent, UploadPdfState> {
  final UploadPdfUseCase uploadPdfUseCase;

  UploadPdfBloc(this.uploadPdfUseCase) : super(UploadPdfInitial()) {
    on<UploadPdfFileEvent>((event, emit) async {
      emit(UploadPdfInProgress());
      try {
        final result = await uploadPdfUseCase.call(File(event.pdfFile.path!));
        emit(UploadPdfSuccess(result));
      } catch (e) {
        emit(UploadPdfFailure(e.toString()));
      }
    });
  }
}
