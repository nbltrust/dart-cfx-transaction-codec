import 'package:conflux_codec/conflux_codec.dart';
import 'package:convert/convert.dart';

void main() {
  // 解析交易获取交易参数的方法
  var trx = ConfluxTransaction.fromRlp(hex.decode('e56468825208941a2f80341409639ea6a35bbcab8299066109aa558204e7808401036e770180'));
  print('nonce: ${trx.nonce}');
  print('gas price: ${trx.gasPrice}');
  print('gas: ${trx.gas}');
  print('to: ${trx.to.toBase32(withAddressType: true)}');
  print('value: ${trx.value}');
  // 这里获取交易中需要签名的hash值
  print('hash to sign: ${hex.encode(trx.hashToSign())}');
}