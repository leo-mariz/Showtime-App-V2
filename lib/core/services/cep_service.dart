import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/errors/exceptions.dart';

class CepInfo {
  final String cep;
  final String? street; // logradouro
  final String? district; // bairro
  final String? city; // localidade
  final String? state; // uf
  final String? complement; // complemento

  CepInfo({
    required this.cep,
    this.street,
    this.district,
    this.city,
    this.state,
    this.complement,
  });
}

abstract class ICepService {
  /// Busca informações de endereço a partir de um CEP
  /// Lança [ServerException] em caso de erro
  Future<CepInfo> getAddressByCep(String cep);
}

class CepServiceImpl implements ICepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  @override
  Future<CepInfo> getAddressByCep(String cep) async {
    try {
      // Remove formatação do CEP (remove hífen e espaços)
      final cleanCep = cep.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanCep.length != 8) {
        throw const ServerException('CEP deve conter 8 dígitos');
      }

      final url = Uri.parse('$_baseUrl/$cleanCep/json/');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw ServerException(
          'Erro ao buscar CEP: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);

      if (data['erro'] == true) {
        throw const ServerException('CEP não encontrado');
      }

      return CepInfo(
        cep: data['cep'] ?? cleanCep,
        street: data['logradouro'],
        district: data['bairro'],
        city: data['localidade'],
        state: data['uf'],
        complement: data['complemento'],
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Erro ao buscar informações do CEP',
        originalError: e,
      );
    }
  }
}

