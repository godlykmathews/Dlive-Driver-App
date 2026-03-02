import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/invoice_group.dart';
import '../models/route_info.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const _baseUrl = 'https://driver-backend-5sb9.onrender.com/api/v1';

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${AuthService.instance.token}',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    String message = 'Request failed';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['detail']?.toString() ?? message;
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<({String token, User user})> login(
      String email, String password) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 30));

    final data = await _handleResponse(response);
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    return (token: token, user: user);
  }

  Future<void> logout() async {
    try {
      await http
          .post(
            Uri.parse('$_baseUrl/logout'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  Future<List<RouteInfo>> getDriverRoutes() async {
    final uri = Uri.parse('$_baseUrl/driver-routes');
    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(seconds: 30));
    final data = await _handleResponse(response);
    final routes = data['routes'] as List<dynamic>? ?? [];
    return routes
        .map((e) => RouteInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InvoiceGroup>> getGroupedInvoices({
    int? routeNumber,
    String? createdDate,
    String? statusFilter,
  }) async {
    final params = <String, String>{};
    if (routeNumber != null) params['route_number'] = routeNumber.toString();
    if (createdDate != null) params['created_date'] = createdDate;
    if (statusFilter != null) params['status'] = statusFilter;

    final uri = Uri.parse('$_baseUrl/invoices-grouped')
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(seconds: 30));

    final data = await _handleResponse(response);
    final groups = data['groups'] as List<dynamic>? ?? [];
    return groups
        .map((e) => InvoiceGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GroupDetail> getGroupDetail(String groupId) async {
    final encodedId = Uri.encodeComponent(groupId);
    final uri = Uri.parse('$_baseUrl/customer-group/$encodedId');

    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(seconds: 30));

    final data = await _handleResponse(response);
    return GroupDetail.fromJson(data);
  }

  Future<void> acknowledgeGroup({
    required String groupId,
    required Uint8List signatureBytes,
    String? notes,
  }) async {
    final encodedId = Uri.encodeComponent(groupId);
    final uri = Uri.parse('$_baseUrl/acknowledge-group/$encodedId');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${AuthService.instance.token}'
      ..files.add(http.MultipartFile.fromBytes(
        'signature',
        signatureBytes,
        filename: 'signature.png',
      ));

    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Server error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['detail']?.toString() ?? message;
      } catch (_) {
        if (response.body.isNotEmpty) message = response.body;
      }
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}
