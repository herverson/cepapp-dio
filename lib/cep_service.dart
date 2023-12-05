import 'package:dio/dio.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class CEPService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> consultarCEP(String cep) async {
    final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');
    return response.data;
  }

  Future<void> cadastrarCEP(Map<String, dynamic> cepData) async {
    final parseObject = ParseObject('CEP');

    cepData.forEach((key, value) {
      parseObject.set(key, value);
    });

    await parseObject.save();
  }

  Future<List<ParseObject>> listarCEPs() async {
    final queryBuilder = QueryBuilder(ParseObject('CEP'));
    final response = await queryBuilder.query();
    return response.results?.cast<ParseObject>() ?? [];
  }

  Future<void> atualizarCEP(
      String objectId, Map<String, dynamic> cepData) async {
    final parseObject = ParseObject('CEP')..objectId = objectId;

    cepData.forEach((key, value) {
      parseObject.set(key, value);
    });

    await parseObject.save();
  }

  Future<void> excluirCEP(String objectId) async {
    final parseObject = ParseObject('CEP')..objectId = objectId;
    await parseObject.delete();
  }
}
