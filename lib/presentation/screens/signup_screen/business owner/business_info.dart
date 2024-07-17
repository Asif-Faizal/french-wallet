import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';

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

  final List<String> _businessTypeOptions = [
    'Sole Proprietorship',
    'Partnership',
    'Corporation',
    'Limited Liability Company (LLC)',
    'Nonprofit'
  ];

  final List<String> _industrySectorOptions = [
    'Agriculture',
    'Manufacturing',
    'Construction',
    'Retail',
    'Finance',
    'Healthcare',
    'Technology',
    'Education',
    'Transportation',
    'Other'
  ];

  @override
  void dispose() {
    _legalNameController.dispose();
    _registrationNumberController.dispose();
    _officialWebsiteController.dispose();
    _officialEmailController.dispose();
    _companyNumberController.dispose();
    super.dispose();
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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Business Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedBusinessType,
              items: _businessTypeOptions
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBusinessType = value;
                });
              },
            ),
            SizedBox(height: size.height / 40),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Industry Sector',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedIndustrySector,
              items: _industrySectorOptions
                  .map((sector) => DropdownMenuItem<String>(
                        value: sector,
                        child: Text(sector),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIndustrySector = value;
                });
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
                        : 'Incorporation Date: ${_selectedDate!.toLocal()}'
                            .split(' ')[0],
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
          title: 'save',
          onPressed: () {
            // Handle submit
          },
        ),
      ),
    );
  }
}
