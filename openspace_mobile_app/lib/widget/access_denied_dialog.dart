import 'package:flutter/material.dart';

Future<void> showAccessDeniedDialog(BuildContext context, {String featureName = "this feature"}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Access Denied'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('No access. You need to log in to use $featureName.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Login'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed('/login');
            },
          ),
        ],
      );
    },
  );
}