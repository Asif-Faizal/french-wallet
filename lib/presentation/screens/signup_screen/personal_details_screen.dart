import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _fathersNameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  String _gender = 'Male';
  DateTime _selectedDate =
      DateTime.now().subtract(Duration(days: 6570)); // 18 years ago
  String _maritalStatus = 'Single';
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_updateButtonState);
    _middleNameController.addListener(_updateButtonState);
    _lastNameController.addListener(_updateButtonState);
    _fathersNameController.addListener(_updateButtonState);
    _nationalityController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_updateButtonState);
    _middleNameController.removeListener(_updateButtonState);
    _lastNameController.removeListener(_updateButtonState);
    _fathersNameController.removeListener(_updateButtonState);
    _nationalityController.removeListener(_updateButtonState);
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _fathersNameController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _fathersNameController.text.isNotEmpty &&
          _nationalityController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
        appBar: NormalAppBar(text: 'Personal Details'),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(
                      'First Name', _firstNameController, theme, size, true),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow(
                      'Middle Name', _middleNameController, theme, size, false),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow(
                      'Last Name', _lastNameController, theme, size, true),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildGenderRow(theme, size),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildDateOfBirthRow(context, theme, size),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow('Father\'s Name', _fathersNameController, theme,
                      size, true),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow(
                      'Nationality', _nationalityController, theme, size, true),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildMaritalStatusRow(theme, size),
                  SizedBox(
                    height: size.height / 12,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15),
          child: NormalButton(
            size: size,
            title: 'Save',
            onPressed: _isButtonEnabled ? _saveForm : null,
          ),
        ));
  }

  Widget _buildRow(String label, TextEditingController controller,
      ThemeData theme, Size size, bool isRequired) {
    return SizedBox(
      height: size.height / 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
                flex: 2, child: Text(label, style: theme.textTheme.bodyMedium)),
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderRow(ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text('Gender', style: theme.textTheme.bodyMedium)),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Radio(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  Text('Male'),
                  Radio(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOfBirthRow(
      BuildContext context, ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child:
                    Text('Date of Birth', style: theme.textTheme.bodyMedium)),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () async {
                  DateTime eighteenYearsAgo =
                      DateTime.now().subtract(Duration(days: 6570));
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: eighteenYearsAgo,
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _updateButtonState(); // Ensure button state is updated
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    DateFormat.yMMMd().format(_selectedDate),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaritalStatusRow(ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child:
                    Text('Marital Status', style: theme.textTheme.bodyMedium)),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _maritalStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    _maritalStatus = newValue!;
                  });
                },
                items: <String>['Single', 'Married', 'Divorced', 'Widowed']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      GoRouter.of(context).pushNamed(AppRouteConst.addressDetailsRoute);
    } else {
      // Show validation errors
    }
  }
}
