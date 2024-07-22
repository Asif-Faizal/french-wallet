import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';

class RetailReceiveScreen extends StatefulWidget {
  const RetailReceiveScreen({super.key});

  @override
  State<RetailReceiveScreen> createState() => _RetailReceiveScreenState();
}

class _RetailReceiveScreenState extends State<RetailReceiveScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  bool _isButtonEnabled = false;
  Iterable<Contact> _contacts = [];
  Iterable<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
    _requestContactPermission();
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length == 10;
    });
  }

  Future<void> _requestContactPermission() async {
    final permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      _loadContacts();
    } else {
      // Handle permission denied
    }
  }

  void _loadContacts() async {
    final contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  void _showContactPicker() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      context: context,
      builder: (context) {
        return Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Contacts',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      _filteredContacts = _contacts;
                    } else {
                      _filteredContacts = _contacts.where((contact) {
                        final name = contact.displayName?.toLowerCase() ?? '';
                        final search = value.toLowerCase();
                        return name.contains(search);
                      }).toList();
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts.elementAt(index);
                  return ListTile(
                    leading:
                        (contact.avatar != null && contact.avatar!.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar!),
                              )
                            : CircleAvatar(child: Text(contact.initials())),
                    title: Text(contact.displayName ?? ''),
                    subtitle:
                        contact.phones != null && contact.phones!.isNotEmpty
                            ? Text(contact.phones!.first.value ?? '')
                            : null,
                    onTap: () {
                      if (contact.phones != null &&
                          contact.phones!.isNotEmpty) {
                        final phoneNumber = contact.phones!.first.value ?? '';
                        _phoneController.text = phoneNumber;
                        _phoneNumber = PhoneNumber(
                          phoneNumber: phoneNumber,
                          isoCode: _phoneNumber.isoCode,
                        );
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: 'Receive Money'),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height / 60,
          horizontal: size.width / 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 20),
            Text(
              'Enter Phone Number',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: size.height / 40),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                setState(() {
                  _phoneNumber = number;
                });
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              initialValue: _phoneNumber,
              textFieldController: _phoneController,
              formatInput: false,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputDecoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                hintText: 'Phone Number',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _showContactPicker,
                  child: Text(
                    'Select from Contacts',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Submit',
          onPressed: _isButtonEnabled ? () {} : null,
        ),
      ),
    );
  }
}
