import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleAvatarSelector extends StatelessWidget {
  const CircleAvatarSelector({
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
      case 'retail':
        iconData = Icons.person;
        text = AppLocalizations.of(context)!.retail;
        break;
      case 'merchant':
        iconData = Icons.person_4;
        text = AppLocalizations.of(context)!.merchant;
        break;
      case 'agent':
        iconData = Icons.security;
        text = AppLocalizations.of(context)!.agent;
        break;
      case 'corporate':
        iconData = Icons.apartment;
        text = AppLocalizations.of(context)!.corporate;
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
