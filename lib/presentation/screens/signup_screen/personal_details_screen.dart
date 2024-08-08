import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final FocusNode _firstName = FocusNode();
  final FocusNode _middleName = FocusNode();
  final FocusNode _lastName = FocusNode();
  final FocusNode _fathersName = FocusNode();
  final FocusNode _nationality = FocusNode();
  final FocusNode _martialStatusNode = FocusNode();
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now().subtract(Duration(days: 6570));
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

  InputDecoration _getInputDecoration(String labelText, FocusNode focusNode) {
    return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue.shade300),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
        enabledBorder: focusNode.hasFocus
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue.shade300, width: 0),
              ));
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
                  _buildRow('First Name', _firstNameController, theme, size,
                      true, _firstName),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow('Middle Name', _middleNameController, theme, size,
                      false, _middleName),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow('Last Name', _lastNameController, theme, size, true,
                      _lastName),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow('Father\'s Name', _fathersNameController, theme,
                      size, true, _fathersName),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  _buildRow('Nationality', _nationalityController, theme, size,
                      true, _nationality),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  Text(
                    'Date of Birth:',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: size.height / 80,
                  ),
                  _buildDateOfBirthRow(context, theme, size),
                  SizedBox(
                    height: size.height / 30,
                  ),
                  Text(
                    'Gender:',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  _buildGenderRow(theme, size),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  Text(
                    'Martial Status:',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  _buildMaritalStatusRow(theme, size),
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
      ThemeData theme, Size size, bool isRequired, FocusNode focusNode) {
    return SizedBox(
      height: size.height / 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextField(
            controller: controller,
            decoration: _getInputDecoration(label, focusNode)),
      ),
    );
  }

  Widget _buildGenderRow(ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
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
    );
  }

  Widget _buildDateOfBirthRow(
      BuildContext context, ThemeData theme, Size size) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
      height: size.height / 17,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
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
                _updateButtonState();
              });
            }
          },
          child: Center(
            child: Text(
              DateFormat.yMMMd().format(_selectedDate),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaritalStatusRow(ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: DropdownButtonFormField<String>(
          decoration: _getInputDecoration('', _martialStatusNode),
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
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final dobYear = _selectedDate.year;
      final dobMonth = _selectedDate.month;
      final dobDay = _selectedDate.day;
      final String dob = '$dobYear-$dobMonth,$dobDay';
      await prefs.setString('firstName', _firstNameController.text);
      await prefs.setString('fullName',
          '${_firstNameController.text} ${_lastNameController.text}');
      await prefs.setString('gender', _gender);
      await prefs.setString('dob', dob);
      await prefs.setString('nationality', _nationalityController.text);
      GoRouter.of(context).pushNamed(AppRouteConst.addressDetailsRoute);
    } else {
      print('Form is invalid');
    }
  }
}
