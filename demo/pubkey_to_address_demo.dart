import 'package:conflux_codec/conflux_codec.dart';

void main() {
  // 这里是从20byte的16进制地址转成32进制地址的方法
  var addr = Address.fromHex('0x1a2f80341409639ea6a35bbcab8299066109aa55');
  print(addr.toBase32(withAddressType: true));

  // 从公钥转生产环境地址的方法
  print(publicKeyToAddress('4646ae5047316b4230d0086c8acec687f00b1cd9d1dc634f6cb358ac0a9a8fff', 'fe77b4dd0a4bfb95851f3b7355c781dd60f8418fc8a65d14907aff47c903a559'));
}