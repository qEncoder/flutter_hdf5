import 'dart:ffi';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ffi/ffi.dart';
import 'package:hdf5/src/bindings/H5T.dart';

Pointer<Uint8> strToChar(String string) {
  Pointer<Uint8> stringPtr = calloc<Uint8>(string.length + 1);
  Uint8List stringList = Uint8List.fromList(string.codeUnits);

  for (var i = 0; i < stringList.length; i++) {
    stringPtr[i] = stringList[i];
  }
  stringPtr[stringList.length] = 0; // terminate with null.
  return stringPtr;
}

String charToString(Pointer<Uint8> charstr, {maxLen = -1, H5T_cset_t cset = H5T_cset_t.ASCII}) {
  switch (cset) {
    case H5T_cset_t.ASCII:
      return charToStringASCII(charstr, maxLen: maxLen);
    case H5T_cset_t.UTF8:
      return charToStringUTF8(charstr, maxLen: maxLen);
    default:
      throw Exception("Unsupported character set");
  }
}

String charToStringASCII(Pointer<Uint8> charstr, {maxLen = -1}) {
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

String charToStringUTF8(Pointer<Uint8> charstr, {maxLen = -1}) {
  // this uses utf8 encoding.
  int lenStr = 0;
  List<int> uint8List = [];
  while (charstr[lenStr] != 0 && (maxLen == -1 || lenStr < maxLen)) {
    uint8List.add(charstr[lenStr]);
    lenStr++;
  }
  final utf8Decoder = utf8.decoder;
  final output = utf8Decoder.convert(uint8List);
  return output;
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