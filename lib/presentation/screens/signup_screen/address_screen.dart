import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final TextEditingController _commStreetAddressController =
      TextEditingController();
  final TextEditingController _commCityController = TextEditingController();
  final TextEditingController _commStateController = TextEditingController();
  final TextEditingController _commZipCodeController = TextEditingController();
  final TextEditingController _commCountryController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _sameAsResidential = false;

  @override
  void initState() {
    super.initState();
    _streetAddressController.addListener(_updateButtonState);
    _cityController.addListener(_updateButtonState);
    _stateController.addListener(_updateButtonState);
    _zipCodeController.addListener(_updateButtonState);
    _countryController.addListener(_updateButtonState);

    _commStreetAddressController.addListener(_updateButtonState);
    _commCityController.addListener(_updateButtonState);
    _commStateController.addListener(_updateButtonState);
    _commZipCodeController.addListener(_updateButtonState);
    _commCountryController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _streetAddressController.removeListener(_updateButtonState);
    _cityController.removeListener(_updateButtonState);
    _stateController.removeListener(_updateButtonState);
    _zipCodeController.removeListener(_updateButtonState);
    _countryController.removeListener(_updateButtonState);

    _commStreetAddressController.removeListener(_updateButtonState);
    _commCityController.removeListener(_updateButtonState);
    _commStateController.removeListener(_updateButtonState);
    _commZipCodeController.removeListener(_updateButtonState);
    _commCountryController.removeListener(_updateButtonState);

    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();

    _commStreetAddressController.dispose();
    _commCityController.dispose();
    _commStateController.dispose();
    _commZipCodeController.dispose();
    _commCountryController.dispose();

    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _streetAddressController.text.isNotEmpty &&
          _cityController.text.isNotEmpty &&
          _stateController.text.isNotEmpty &&
          _zipCodeController.text.isNotEmpty &&
          _countryController.text.isNotEmpty &&
          (_sameAsResidential ||
              (_commStreetAddressController.text.isNotEmpty &&
                  _commCityController.text.isNotEmpty &&
                  _commStateController.text.isNotEmpty &&
                  _commZipCodeController.text.isNotEmpty &&
                  _commCountryController.text.isNotEmpty));
    });
  }

  void _toggleSameAsResidential(bool? value) {
    setState(() {
      _sameAsResidential = value ?? false;

      if (_sameAsResidential) {
        _commStreetAddressController.text = _streetAddressController.text;
        _commCityController.text = _cityController.text;
        _commStateController.text = _stateController.text;
        _commZipCodeController.text = _zipCodeController.text;
        _commCountryController.text = _countryController.text;
      } else {
        _commStreetAddressController.clear();
        _commCityController.clear();
        _commStateController.clear();
        _commZipCodeController.clear();
        _commCountryController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: NormalAppBar(
        text: 'Address Details',
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Residential address',
                      style: theme.textTheme.headlineMedium),
                  SizedBox(height: size.height / 60),
                  _buildRow(
                      'Street Address', _streetAddressController, theme, size),
                  SizedBox(height: size.height / 60),
                  _buildRow('City', _cityController, theme, size),
                  SizedBox(height: size.height / 60),
                  _buildRow('State', _stateController, theme, size),
                  SizedBox(height: size.height / 60),
                  _buildPinCodeRow('Zip Code', _zipCodeController, theme, size),
                  SizedBox(height: size.height / 60),
                  _buildRow('Country', _countryController, theme, size),
                  SizedBox(height: size.height / 40),
                  Text('Communication address',
                      style: theme.textTheme.headlineMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _sameAsResidential,
                        onChanged: _toggleSameAsResidential,
                      ),
                      Text('Same as residential address',
                          style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  if (!_sameAsResidential) ...[
                    _buildRow('Comm. Street Address',
                        _commStreetAddressController, theme, size),
                    SizedBox(height: size.height / 60),
                    _buildRow('Comm. City', _commCityController, theme, size),
                    SizedBox(height: size.height / 60),
                    _buildRow('Comm. State', _commStateController, theme, size),
                    SizedBox(height: size.height / 60),
                    _buildPinCodeRow(
                        'Comm. Zip Code', _commZipCodeController, theme, size),
                    SizedBox(height: size.height / 60),
                    _buildRow(
                        'Comm. Country', _commCountryController, theme, size),
                    SizedBox(height: size.height / 60),
                  ],
                  SizedBox(height: size.height / 40),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: NormalButton(
          size: size,
          title: 'Save',
          onPressed: _isButtonEnabled ? _saveForm : null,
        ),
      ),
    );
  }

  Widget _buildRow(String label, TextEditingController controller,
      ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 15,
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

  Widget _buildPinCodeRow(String label, TextEditingController controller,
      ThemeData theme, Size size) {
    return SizedBox(
      height: size.height / 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
                flex: 2, child: Text(label, style: theme.textTheme.bodyMedium)),
            Expanded(
              flex: 3,
              child: TextField(
                maxLength: 6,
                keyboardType: TextInputType.number,
                controller: controller,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      GoRouter.of(context).pushNamed(AppRouteConst.addEmailRoute);
    } else {
      // Show validation errors
    }
  }
}
