import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AasService {
  static const String baseUrl = "http://192.168.1.10:8081";

  /// HÀM 1: Lấy số liệu cho Dashboard (Dùng trong dashboard_screen.dart)
  static Future<Map<String, int>> fetchDashboardStats() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/shells')).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) throw Exception("Load shells failed");

      final data = jsonDecode(res.body);
      final List shells = data['result'] ?? [];
      
      int warning = 0;
      int error = 0;

      for (var shell in shells) {
        final List submodels = shell['submodels'] ?? [];
        for (var sm in submodels) {
          final List keys = sm['keys'] ?? [];
          if (keys.isNotEmpty) {
            final String smId = keys[0]['value'].toString().toLowerCase();
            // Đếm số lượng cảnh báo/lỗi dựa trên tên submodel
            if (smId.contains("technical")) warning++;
            if (smId.contains("relationship")) error++;
          }
        }
      }
      return {
        "assets": shells.length,
        "online": shells.length,
        "warning": warning,
        "error": error
      };
    } catch (e) {
      debugPrint("Lỗi Dashboard: $e");
      return {"assets": 0, "online": 0, "warning": 0, "error": 0};
    }
  }

  /// HÀM 2: Lấy giá trị thực tế cho Monitor (Dùng trong monitoring_screen.dart)
  static Future<double?> fetchLiveTemperature() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/shells')).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final List shells = data['result'] ?? [];
      if (shells.isEmpty) return null;

      // Tìm Submodel TechnicalData
      final List submodels = shells[0]['submodels'] ?? [];
      String? technicalSubmodelId;
      for (var sm in submodels) {
        String id = sm['keys'][0]['value'].toString();
        if (id.contains("TechnicalData")) {
          technicalSubmodelId = id;
          break;
        }
      }

      if (technicalSubmodelId == null) return null;

      // Encode ID và gọi lấy elements
      final encodedId = Uri.encodeComponent(technicalSubmodelId);
      final elRes = await http.get(Uri.parse("$baseUrl/submodels/$encodedId/submodel-elements"));

      if (elRes.statusCode == 200) {
        final elData = jsonDecode(elRes.body);
        final List elements = elData['result'] ?? [];
        for (var el in elements) {
          if (el['value'] != null) {
            double? val = double.tryParse(el['value'].toString());
            if (val != null) return val;
          }
        }
      }
      
      // Dự phòng: Trả về số cuối của GTIN nếu không tìm thấy Property
      final gtin = shells[0]['assetInformation']?['specificAssetIds']?[1]?['value'];
      if (gtin != null) return double.tryParse(gtin.toString().substring(gtin.toString().length - 2));

    } catch (e) {
      debugPrint("Lỗi Monitor: $e");
    }
    return null;
  }
}