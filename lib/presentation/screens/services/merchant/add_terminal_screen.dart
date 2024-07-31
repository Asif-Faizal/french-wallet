import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';

class AddTerminalScreen extends StatefulWidget {
  final int storeId;

  AddTerminalScreen({required this.storeId});

  @override
  _AddTerminalScreenState createState() => _AddTerminalScreenState();
}

class _AddTerminalScreenState extends State<AddTerminalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _modelController = TextEditingController();
  final _idController = TextEditingController();
  final _serialController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: 'Add Terminal'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Store ID: ${widget.storeId}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              _buildTextField(
                  controller: _locationController, label: 'Location'),
              _buildTextField(controller: _nameController, label: 'Name'),
              _buildTextField(controller: _typeController, label: 'Type'),
              _buildTextField(controller: _modelController, label: 'Model'),
              _buildTextField(controller: _idController, label: 'ID'),
              _buildTextField(controller: _serialController, label: 'Serial'),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: MediaQuery.of(context).size,
          title: 'Add',
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
