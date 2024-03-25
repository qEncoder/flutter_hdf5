import 'dart:ffi';

final class H5FD_ros3_fapl_t extends Struct {
  @Int32()
  external int version;

  @Bool()
  external bool authenticate;

  @Array<Uint8>(32+1)
  external Array<Uint8> aws_region;

  @Array<Uint8>(128+1)
  external Array<Uint8> secret_id;

  @Array<Uint8>(128+1)
  external Array<Uint8> secret_key;
}
