import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class PinInputController {
  ValueNotifier<String> pin = ValueNotifier<String>("");

  void addNumber(BuildContext context, String number) {
    if (pin.value.length < 6) { // 최대 6자리 입력 가능
      pin.value += number;
    }

    if(pin.value.length == 6) {
      if(pin.value == '111111') {
        context.go('/home');
      } else {
        pin.value = '';
      }
    }
  }

  void deleteNumber() {
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }
}
