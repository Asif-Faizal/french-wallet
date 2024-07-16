import 'package:flutter/material.dart';

class NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NormalAppBar({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
