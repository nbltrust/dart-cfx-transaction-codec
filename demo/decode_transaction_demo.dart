import 'package:conflux_codec/conflux_codec.dart';
import 'package:convert/convert.dart';

void main() {
  // 解析交易获取交易参数的方法
  var trx = ConfluxTransaction.fromRlp(hex.decode(
      'eb8002825209941af14c0ebee455b07d72525f470815cff22bebcc888ac7230489e800008084014677be0180'));
  print('nonce: ${trx.nonce}');
  print('gas price: ${trx.gasPrice}');
  print('gas: ${trx.gas}');
  print('to: ${trx.to.toBase32()}');
  print('value: ${trx.value}');
  // 这里获取交易中需要签名的hash值
  print('hash to sign: ${hex.encode(trx.hashToSign())}');
}
