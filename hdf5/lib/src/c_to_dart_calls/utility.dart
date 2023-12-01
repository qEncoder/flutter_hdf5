import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

Pointer<Uint8> strToChar(String string) {
  Pointer<Uint8> stringPtr = calloc.allocate<Uint8>(string.length + 1);
  Uint8List stringList = Uint8List.fromList(string.codeUnits);

  for (var i = 0; i < stringList.length; i++) {
    stringPtr[i] = stringList[i];
  }
  stringPtr[stringList.length] = 0; // terminate with null.
  return stringPtr;
}

String charToString(Pointer<Uint8> charstr, {int lenStr = 0}) {
  if (lenStr == 0) {
    while (charstr[lenStr] != 0) {
      lenStr++;
    }
  }

  Uint8List stringList = Uint8List(lenStr);

  for (var i = 0; i < lenStr; i++) {
    stringList[i] = charstr[i];
  }

  return String.fromCharCodes(stringList);
}
