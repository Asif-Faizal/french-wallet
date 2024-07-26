import 'package:ewallet2/presentation/bloc/industry%20sector/industry_sector_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/signup/business_type_entity.dart';
import '../../../../domain/signup/industry_type_entity.dart';
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
              decoration: InputDecoration(
                labelText: 'Legal Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _registrationNumberController,
              decoration: InputDecoration(
                labelText: 'Registration Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _officialWebsiteController,
              decoration: InputDecoration(
                labelText: 'Official Website',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _officialEmailController,
              decoration: InputDecoration(
                labelText: 'Official Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _companyNumberController,
              decoration: InputDecoration(
                labelText: 'Company Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            BlocBuilder<BusinessTypeBloc, BusinessTypeState>(
              builder: (context, state) {
                if (state is BusinessTypeLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is BusinessTypeLoaded) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                  return Center(child: CircularProgressIndicator());
                } else if (state is IndustrySectorLoaded) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Industry Sector',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                  decoration: InputDecoration(
                    labelText: _selectedDate == null
                        ? 'Date of Incorporation'
                        : '${_selectedDate!.toLocal()}'.split(' ')[0],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
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
              ? () {
                  GoRouter.of(context).pushNamed(AppRouteConst.uploadPdfRoute);
                }
              : null,
        ),
      ),
    );
  }
}
