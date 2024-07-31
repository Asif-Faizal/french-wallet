import 'package:flutter/material.dart';
import '../../screens/services/merchant/add_terminal_screen.dart';

import '../../../data/store/store_model.dart';

class StoreCard extends StatefulWidget {
  final Store store;

  StoreCard({required this.store});

  @override
  _StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.store.storeName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(widget.store.storeLocation),
            SizedBox(height: 20),
            if (widget.store.terminalArray != null &&
                widget.store.terminalArray!.isNotEmpty)
              ExpansionTile(
                title: Text('View Terminals'),
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _isExpanded = expanded;
                  });
                },
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.store.terminalArray!.map((terminal) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terminal Name: ${terminal.terminalName}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('Type: ${terminal.terminalType}'),
                            Text('Model: ${terminal.terminalModel}'),
                            Text('ID: ${terminal.terminalId}'),
                            Text('Serial: ${terminal.terminalSerialnum}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (_isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddTerminalScreen(
                                storeId: widget.store.storeId,
                              ),
                            ),
                          );
                        },
                        child: Text('Add Terminal'),
                      ),
                    ),
                ],
              )
            else
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddTerminalScreen(
                          storeId: widget.store.storeId,
                        ),
                      ),
                    );
                  },
                  child: Text('Add Terminal'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
