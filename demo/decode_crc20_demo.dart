import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eth_abi_codec/eth_abi_codec.dart';
import 'package:ethereum_codec/src/contracts.dart';
import 'package:ethereum_codec/src/translator.dart';

import 'package:conflux_codec/conflux_codec.dart';
import 'package:convert/convert.dart';

void initAbi() {
  var symbolFile = File('contract_abi/contract_symbols.json');
  var symbols = jsonDecode(symbolFile.readAsStringSync());

  var abis = (symbols as List)
      .map((s) => <String, dynamic>{
            'type': s['type'] as String,
            'abi': jsonDecode(
                File('contract_abi/abi/${s['type'].toUpperCase()}.json').readAsStringSync())
          })
      .toList();

  AddressConfig.createInstance(symbols, abis);
}

Map<String, dynamic>? getContractInfo(addr, input) {
  final contractCfg = AddressConfig.instance?.getContractConfigByAddress(addr);

  if (contractCfg == null) {
    if (input.length == 0) {
      return {};
    } else {
      return null;
    }
  }
  var abi = getContractABIByType(contractCfg.type);
  if(abi == null) return null;
  var call_info = ContractCall.fromBinary(input, abi);
  return {
    'symbol': contractCfg.symbol,
    'type': contractCfg.type,
    'contract_params': contractCfg.params,
    'method': call_info.functionName,
    'params': call_info.callParams
  };
}

void main() {
  initAbi();

  // 解析交易获取交易参数的方法
  var trx = ConfluxTransaction.fromRlp(Uint8List.fromList(hex.decode(
      'f8686a01825958948ba2e83e8d58ad37c91ad72ea35961846b16793b80808401b791cf01b844a9059cbb0000000000000000000000001ead8630345121d19ee3604128e5dc54b36e8ea60000000000000000000000000000000000000000000000000000000000000001')));

  final isContract = trx.to?.toBase32(withAddressType: true).contains("type.contract");
  if (isContract != null && isContract) {
    final contract = getContractInfo(trx.to!.toBase32(), trx.data);
    if (contract != null) {
      // it's a contract call
      print('contract type: ${contract['type']}'); // CRC20
      print('contract method: ${contract['method']}'); // transfer
      print('contract params: ${contract['contract_params']}');
      final toAddr = Address.fromHex(contract['params']['_to'],
              netPrefix: trx.chainId == 1 ? 'cfxtest' : 'cfx')
          .toBase32();
      print('to address: ${toAddr}'); // cfxtest:aatm5bvugvjwdyp86ruecmhf5vmng5ysy2pehzpz9h
      print('value: ${contract['params']['_value']}'); // 1
    }
  }

  print('nonce: ${trx.nonce}'); // 106
  print('gas price: ${trx.gasPrice}'); // 1
  print('gas: ${trx.gas}'); // 22872
  print('to: ${trx.to?.toBase32()}'); // cfxtest:acf4f4b8vzpm4r8kdnnw7j43pgcg0fx3hpkze0zzeu
  print('value: ${trx.value}');
  if(trx.data != null){
    print(
        'data: ${hex.encode(trx.data!)}');
  }// 0
// a9059cbb0000000000000000000000001ead8630345121d19ee3604128e5dc54b36e8ea60000000000000000000000000000000000000000000000000000000000000001
  // 这里获取交易中需要签名的hash值
  if(trx.hashToSign() != null){
    print('hash to sign: ${hex.encode(trx.hashToSign()!)}');
  }

}
