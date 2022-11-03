library conflux_codec.transaction;

import 'dart:typed_data';
import 'package:pointycastle/api.dart';

import 'rlp.dart' as RLP;
import 'package:convert/convert.dart';

import './address.dart';

int? arrToInt(List<int> i) {
  if (i.length == 0) return null;
  return int.parse(hex.encode(i), radix: 16);
}

class ConfluxTransaction {
  int? nonce;
  int? gasPrice;
  int? gas;
  Address? to;
  BigInt? value;
  int? storageLimit;
  int? epochHeight;
  int? chainId;
  List<int>? data;
  Uint8List? rlp;

  ConfluxTransaction(this.nonce, this.gasPrice, this.gas, this.to, this.value, this.storageLimit,
      this.epochHeight, this.chainId, this.data, this.rlp);
  factory ConfluxTransaction.fromRlp(Uint8List rlp) {
    List<dynamic> t = RLP.decode(rlp);
    var value = BigInt.zero;
    try {
      value = BigInt.parse(hex.encode(t[4]), radix: 16);
    } catch (e) {
      //ignore error
    }

    final chainId = arrToInt(t[7]);

    return ConfluxTransaction(
        arrToInt(t[0]) ?? 0,
        arrToInt(t[1]),
        arrToInt(t[2]),
        Address.fromHex(hex.encode(t[3]), netPrefix: chainId == 1 ? 'cfxtest' : 'cfx'),
        value,
        arrToInt(t[5]),
        arrToInt(t[6]),
        chainId,
        t[8],
        rlp);
  }

  Uint8List? hashToSign() {
    if(rlp == null) return null;
    return Digest('Keccak/256').process(rlp!);
  }
}
