import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:flutter/material.dart';

class TransactionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: NormalAppBar(text: 'Statements'), body: Container());
  }
}
