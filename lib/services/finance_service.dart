import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/finance_model.dart';

class FinanceService {
  static const String baseUrl = 'https://7b77-2400-9800-700-d4dd-73bf-d5a4-b1ed-4575.ngrok-free.app';

  static Future<List<Finance>> getAllFinances() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1-finances'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((e) => Finance.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data keuangan');
    }
  }

  static Future<Finance> getFinanceById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1-finances/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body)['data'];
      return Finance.fromJson(data);
    } else {
      throw Exception('Data tidak ditemukan');
    }
  }

  static Future<void> deleteFinance(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/v1-finances/$id'));

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data');
    }
  }

  static Future<void> createFinance(Finance data, File? photo) async {
    final uri = Uri.parse('$baseUrl/api/v1-finances');
    var request = http.MultipartRequest('POST', uri);

    request.fields['title'] = data.title;
    request.fields['type'] = data.type;
    request.fields['date'] = data.date;
    request.fields['amount'] = data.amount.toString();
    request.fields['description'] = data.description;

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambahkan data');
    }
  }

  static Future<void> updateFinance(int id, Finance data, File? photo) async {
    final uri = Uri.parse('$baseUrl/api/v1-finances/$id');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['title'] = data.title;
    request.fields['type'] = data.type;
    request.fields['date'] = data.date;
    request.fields['amount'] = data.amount.toString();
    request.fields['description'] = data.description;

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate data');
    }
  }
}
