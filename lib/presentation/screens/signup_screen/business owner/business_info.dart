import 'package:ewallet2/presentation/bloc/industry%20sector/industry_sector_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/signup/business_type/business_type_entity.dart';
import '../../../../domain/signup/industry_sector/industry_type_entity.dart';
import '../../../../shared/router/router_const.dart';
import '../../../bloc/business info/business_info_bloc.dart';
import '../../../widgets/shared/normal_appbar.dart';
import '../../../widgets/shared/normal_button.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _officialWebsiteController =
      TextEditingController();
  final TextEditingController _officialEmailController =
      TextEditingController();
  final TextEditingController _companyNumberController =
      TextEditingController();
  String? _selectedBusinessType;
  String? _selectedIndustrySector;
  DateTime? _selectedDate;

  bool get _isButtonEnabled {
    return _legalNameController.text.isNotEmpty &&
        _registrationNumberController.text.isNotEmpty &&
        _officialWebsiteController.text.isNotEmpty &&
        _officialEmailController.text.isNotEmpty &&
        _companyNumberController.text.isNotEmpty &&
        _selectedBusinessType != null &&
        _selectedIndustrySector != null &&
        _selectedDate != null;
  }

  @override
  void initState() {
    super.initState();
    _legalNameController.addListener(_updateButtonState);
    _registrationNumberController.addListener(_updateButtonState);
    _officialWebsiteController.addListener(_updateButtonState);
    _officialEmailController.addListener(_updateButtonState);
    _companyNumberController.addListener(_updateButtonState);

    context.read<BusinessTypeBloc>().add(FetchBusinessTypes());
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _legalNameController,
              decoration: _getInputDecoration('Legal Name'),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _registrationNumberController,
              decoration: _getInputDecoration('Registration Number'),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _officialWebsiteController,
              decoration: _getInputDecoration('Company Website'),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _officialEmailController,
              decoration: _getInputDecoration('Company Mail'),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _companyNumberController,
              decoration: _getInputDecoration('Company Number'),
            ),
            SizedBox(height: size.height / 40),
            BlocBuilder<BusinessTypeBloc, BusinessTypeState>(
              builder: (context, state) {
                if (state is BusinessTypeLoading) {
                  return Center(
                      child: TextField(
                    decoration: _getInputDecoration('Business Type'),
                  ));
                } else if (state is BusinessTypeLoaded) {
                  return DropdownButtonFormField<String>(
                    decoration: _getInputDecoration('Business Type'),
                    value: _selectedBusinessType,
                    items: state.businessTypes
                        .map((BusinessType type) => DropdownMenuItem<String>(
                              value: type.businessType,
                              child: Text(type.businessType),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBusinessType = value;
                      });
                    },
                  );
                } else if (state is BusinessTypeError) {
                  return Text('Failed to load business types');
                }
                return SizedBox();
              },
            ),
            SizedBox(height: size.height / 40),
            BlocBuilder<IndustrySectorBloc, IndustrySectorState>(
              builder: (context, state) {
                if (state is IndustrySectorLoading) {
                  return Center(
                      child: TextField(
                    decoration: _getInputDecoration('Industry Sector'),
                  ));
                } else if (state is IndustrySectorLoaded) {
                  return DropdownButtonFormField<String>(
                    decoration: _getInputDecoration('Industry Sector'),
                    value: _selectedIndustrySector,
                    items: state.industrySectors
                        .map(
                            (IndustrySector sector) => DropdownMenuItem<String>(
                                  value: sector.industrySector,
                                  child: Text(sector.industrySector),
                                ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIndustrySector = value;
                      });
                    },
                  );
                } else if (state is IndustrySectorError) {
                  return Text('Failed to load industry sectors');
                }
                return SizedBox();
              },
            ),
            SizedBox(height: size.height / 40),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                    decoration: _getInputDecoration(
                  _selectedDate == null
                      ? 'Date of Incorporation'
                      : '${_selectedDate!.toLocal()}'.split(' ')[0],
                )),
              ),
            ),
            SizedBox(height: size.height / 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Save',
          onPressed: _isButtonEnabled
              ? () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString(
                      'companyWebsite', _officialWebsiteController.text);
                  await prefs.setString(
                      'companyMail', _officialEmailController.text);
                  await prefs.setString(
                      'companyPhone', _companyNumberController.text);
                  await prefs.setString('businessType', _selectedBusinessType!);
                  await prefs.setString(
                      'industryType', _selectedIndustrySector!);
                  GoRouter.of(context).pushNamed(AppRouteConst.uploadPdfRoute);
                }
              : null,
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String labelText) {
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 0),
        ));
  }
}
