library conflux_codec.address;
// This file implements conflux address convertions defined in CIP-37
// https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-37.md

import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/sha3.dart';

var BASE32_CHARS = [
  'a','b','c','d','e','f','g','h',
  'j','k','m','n','p','r','s','t',
  'u','v','w','x','y','z','0','1',
  '2','3','4','5','6','7','8','9'
];

Uint8List toBase32Array(Uint8List d) {
  var ret = <int>[];
  var curUsed = 0;
  int i = 0;
  while(i < d.length) {
    int t = 0;
    if(curUsed <= 3) {
      t = (d[i] >> (3 - curUsed)) & 0x1f;
      ret.add(t);
      curUsed += 5;
      if(curUsed >= 8) {
        curUsed = 0;
        i += 1;
      }
    } else {
      t = (d[i] & ((1 << (8 - curUsed)) - 1)) << (curUsed - 3);
      curUsed = curUsed - 3;
      i += 1;
      if(i < d.length) {
        t |= (d[i] >> (8 - curUsed));
      }
      ret.add(t);
    }
  }
  return Uint8List.fromList(ret);
}

String getAddressType(Uint8List address) {
  if (address.length < 1) {
    throw Exception('Empty payload in address');
  }

  switch (address[0] & 0xf0) {
    case 0x10:
      return 'user';
    case 0x80:
      return 'contract';
    case 0x00:
      for (var i = 0; i < address.length; i++) {
        if (address[i] != 0x00) {
          return 'builtin';
        }
      }
      return 'null';
    default:
      throw Exception('Invalid conflux address type, check first byte');
  }
}

class Address {
  Uint8List address; // plain address
  String net_prefix; // cfx | cfxtest | net[n] where n != 1, 1029
  int version_byte;

  Address.fromHex(String hexAddr, {String netPrefix = 'cfx', int version = 0x00}) {
    if(hexAddr.startsWith('0x'))
      hexAddr = hexAddr.substring(2);
    address = Uint8List.fromList([version] + hex.decode(hexAddr));
    net_prefix = netPrefix;
    version_byte = version;
  }

  Uint8List polyMod(Uint8List input) {
    var c = 1;
    input.forEach((d) {
      var c0 = c >> 35;
      c = ((c & 0x07ffffffff) << 5) ^ d;

      if (c0 & 0x01 > 0) c ^= 0x98f2bc8e61;
      if (c0 & 0x02 > 0) c ^= 0x79b76d99e2;
      if (c0 & 0x04 > 0) c ^= 0xf33e5fb3c4;
      if (c0 & 0x08 > 0) c ^= 0xae2eabe2a8;
      if (c0 & 0x10 > 0) c ^= 0x1e4f43e470;
    });
    c ^= 1;

    return toBase32Array(Uint8List.fromList(my_hexdecode(c.toRadixString(16))));
  }

  Uint8List checkSum() {
    // convert net prefix to base32
    var prefix = net_prefix.codeUnits.map((i) => i & 0x1f).toList();
    var checkSumInput = prefix + [0x00] + toBase32Array(address) + [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
    return polyMod(Uint8List.fromList(checkSumInput));
  }

  String toBase32({bool withAddressType = false}) {
    var addressType = 'type.' + getAddressType(address.sublist(1));
    var b32Array = toBase32Array(address) + checkSum();
    var b32Addr = b32Array.map((i) => BASE32_CHARS[i]).join('');
    if (withAddressType) {
      return net_prefix + ':' + addressType + ':' + b32Addr;
    } else {
      return net_prefix + ':' + b32Addr;
    }
  }
}

Uint8List my_hexdecode(String hexStr) {
  return hex.decode((hexStr.length.isOdd ? '0' : '') + hexStr);
}

// 公钥转地址，算checksum的时候需要把network prefix带进去
// 本方法只能计算前缀是cfx（主链）的地址
// 不能计算测试链的地址（前缀是cfxtest）
// 如果要计算测试链地址，需要Address.fromHex(..., networkPrefix: 'cfxtest')
String publicKeyToAddress(String hexX, String hexY,
    {String netPrefix = 'cfx', bool withAddressType = false}) {
  var plainKey = my_hexdecode(hexX) + my_hexdecode(hexY);
  var digest = SHA3Digest(256, true).process(Uint8List.fromList(plainKey));
  var address = digest.sublist(digest.length - 20).toList();
  address[0] = (address[0] & 0x0f) | 0x10;
  return Address.fromHex(hex.encode(address), netPrefix: netPrefix)
      .toBase32(withAddressType: withAddressType);
}
