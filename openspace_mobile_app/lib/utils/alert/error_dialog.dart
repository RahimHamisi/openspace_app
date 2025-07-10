
import 'dart:core';
import 'dart:nativewrappers/_internal/vm_shared/lib/bool_patch.dart';

import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';


  Future<void> showErrorDialog(BuildContext context,
      {String routeName = "this page"}) async {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: 'The route $routeName was not found.',
      confirmBtnText: 'Go to Home',
      showCancelBtn: true,
      showConfirmBtn: true,
      cancelBtnText: 'Cancel',
      confirmBtnColor: Theme
          .of(context)
          .primaryColor,
      onConfirmBtnTap: () {
        Navigator.of(context).pushNamed('/home');
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
      },
      barrierDismissible: false,
    );
  }
