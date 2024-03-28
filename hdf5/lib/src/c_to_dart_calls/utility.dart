import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

Pointer<Uint8> strToChar(String string) {
  Pointer<Uint8> stringPtr = calloc<Uint8>(string.length + 1);
  Uint8List stringList = Uint8List.fromList(string.codeUnits);

  for (var i = 0; i < stringList.length; i++) {
    stringPtr[i] = stringList[i];
  }
  stringPtr[stringList.length] = 0; // terminate with null.
  return stringPtr;
}

String charToString(Pointer<Uint8> charstr, {maxLen = -1}) {
  int lenStr = 0;
  while (charstr[lenStr] != 0 && (maxLen == -1 || lenStr < maxLen)) {
    lenStr++;
  }

  Uint8List stringList = Uint8List(lenStr);

  for (var i = 0; i < lenStr; i++) {
    stringList[i] = charstr[i];
  }

  return String.fromCharCodes(stringList);
}

void strToArray(String string, Array<Uint8> array, int size) {
  if (string.length + 1 > size) {
    throw Exception("String is longer than expected size");
  }

  for (var i = 0; i < string.length; i++) {
    array[i] = string.codeUnitAt(i);
  }
  array[string.length] = 0;

}

Pointer<Int64> IntListToPtrArr(List<int> input) {
  Pointer<Int64> arr = calloc<Int64>(input.length);
  for (var i = 0; i < input.length; i++) {
    arr[i] = input[i];
  }
  return arr;
}
