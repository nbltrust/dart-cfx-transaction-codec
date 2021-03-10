library conflux_codec.transaction;

import 'dart:typed_data';

import 'package:ethereum_util/src/rlp.dart' as eth_rlp;
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/sha3.dart';

import './address.dart';

int arrToInt(List<int> i) {
  if(i.length == 0)
    return null;
  return int.parse(hex.encode(i), radix: 16);
}

class ConfluxTransaction {
  int nonce;
  int gasPrice;
  int gas;
  Address to;
  int value;
  int storageLimit;
  int epochHeight;
  int chainId;
  List<int> data;
  Uint8List rlp;

  ConfluxTransaction(this.nonce, this.gasPrice, this.gas, 
    this.to, this.value, this.storageLimit, this.epochHeight, this.chainId, this.data, this.rlp);
  factory ConfluxTransaction.fromRlp(Uint8List rlp) {
    List<dynamic> t = eth_rlp.decode(rlp);
    return ConfluxTransaction(
      arrToInt(t[0]),
      arrToInt(t[1]),
      arrToInt(t[2]),
      Address.fromHex(hex.encode(t[3])),
      arrToInt(t[4]),
      arrToInt(t[5]),
      arrToInt(t[6]),
      arrToInt(t[7]),
      t[8],
      rlp
    );
  }

  Uint8List hashToSign() {
    return SHA3Digest(256, true).process(rlp);
  }
}
