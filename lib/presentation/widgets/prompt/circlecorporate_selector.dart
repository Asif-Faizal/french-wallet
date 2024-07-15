import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleCorporateSelector extends StatelessWidget {
  const CircleCorporateSelector({
    super.key,
    required this.userType,
    required this.selectedUserType,
    required this.onSelect,
  });

  final String userType;
  final String? selectedUserType;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSelected = selectedUserType == userType;
    IconData iconData;
    String text;

    switch (userType) {
      case 'business-owner':
        iconData = Icons.person_4;
        text = AppLocalizations.of(context)!.business_owner;
        break;
      case 'executive-officer':
        iconData = Icons.laptop_chromebook;
        text = AppLocalizations.of(context)!.executive_officer;
        break;
      case 'employee':
        iconData = Icons.work;
        text = AppLocalizations.of(context)!.employee;
        break;
      default:
        iconData = Icons.error;
        text = '';
    }

    return GestureDetector(
      onTap: () => onSelect(userType),
      child: Column(
        children: [
          Card(
            elevation: isSelected ? 0 : 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: CircleAvatar(
              radius: size.width / 12,
              backgroundColor:
                  isSelected ? Colors.amber.shade300 : Colors.white,
              child: Icon(
                iconData,
                color: isSelected ? Colors.grey.shade900 : Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(
            height: size.height / 60,
          ),
          Text(
            text,
            style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 16 : 14),
          )
        ],
      ),
    );
  }
}
