import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void appNotify(String msg, bool isSuccess, BuildContext context) {
  showToast(
    msg,
    textStyle: const TextStyle(fontSize: 12, color: Colors.white),
    backgroundColor: isSuccess ? Colors.green : Colors.red,
    context: context,
    animation: StyledToastAnimation.scale,
    reverseAnimation: StyledToastAnimation.fade,
    position: StyledToastPosition.top,
    animDuration: const Duration(seconds: 1),
    duration: const Duration(seconds: 4),
    curve: Curves.elasticOut,
    reverseCurve: Curves.linear,
  );
}
