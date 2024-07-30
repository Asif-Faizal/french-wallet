import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/statement/fetch_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FetchTransactions fetchTransactions;

  TransactionBloc({required this.fetchTransactions})
      : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
  }
  void _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await fetchTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(
          'Failed to load transactions. Error: ${e.toString()}'));
    }
  }
}
