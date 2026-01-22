import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertDetailScreen extends StatefulWidget {
  final String submodelApiUrl;

  const AlertDetailScreen({super.key, required this.submodelApiUrl});

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  List<dynamic> elements = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchElements();
  }


Future<void> fetchElements() async {
  if (!mounted) return;

  setState(() {
    isLoading = true;
    error = null;
  });

  try {
    String host = "http://192.168.1.10:8081";
    String submodelRawId = widget.submodelApiUrl;

    // MÃ HÓA BASE64 (Dành cho BaSyx trên Docker)
    // Bước 1: Chuyển chuỗi ID thành mảng bytes (UTF-8)
    List<int> bytes = utf8.encode(submodelRawId);
    // Bước 2: Mã hóa sang Base64
    String base64Id = base64.encode(bytes);
    
    // Cấu trúc URL gọi trực tiếp bằng Base64 ID
    String finalUrl = "$host/submodels/$base64Id/submodel-elements";

    debugPrint("URL GỌI (BASE64): $finalUrl");

    final res = await http.get(
      Uri.parse(finalUrl), 
      headers: {"Accept": "application/json"}
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        elements = data['result'] ?? [];
        isLoading = false;
        if (elements.isEmpty) error = "Submodel này không có dữ liệu.";
      });
    } else {
      // NẾU BASE64 VẪN LỖI 400, THỬ LẠI VỚI URL ENCODING (DÙNG SHELL)
   //   _tryFetchViaShell(); 
    }
  } catch (e) {
    if (mounted) setState(() { error = e.toString(); isLoading = false; });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết AAS"),
        backgroundColor: Colors.blueAccent,
      ),
      // ĐÃ SỬA: RefreshIndicator dùng 'onRefresh' chứ không phải 'onPressed'
      body: RefreshIndicator(
        onRefresh: fetchElements,
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(error!, textAlign: TextAlign.center),
          ),
          const Center(child: Text("Kéo xuống để tải lại")),
        ],
      );
    }

    if (elements.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("Không có dữ liệu hiển thị.")),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: elements.length,
     itemBuilder: (context, i) {
  final item = elements[i];
  String idShort = item['idShort'] ?? "N/A";
  String modelType = item['modelType'] ?? "Unknown";
  
  // Xử lý hiển thị giá trị thông minh hơn
  String displayValue = "";
  if (item['value'] is List) {
    displayValue = "${(item['value'] as List).length} mục bên trong";
  } else {
    displayValue = item['value']?.toString() ?? "Trống";
  }

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: ExpansionTile( // Dùng ExpansionTile để bấm vào xổ ra xem chi tiết
      leading: Icon(
        modelType == "Property" ? Icons.article : Icons.folder,
        color: Colors.blueAccent,
      ),
      title: Text(idShort, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Loại: $modelType"),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            item['value'].toString(), // Hiện chi tiết JSON khi mở rộng
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        )
      ],
    ),
  );
},
    );
  }
}
