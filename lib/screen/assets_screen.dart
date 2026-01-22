import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screen/asseta_detail.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  List assets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

 Future<void> fetchAssets() async {
  try {
    final url = Uri.parse("http://192.168.1.10:8081/shells"); // máy thật
    final response = await http.get(url);

    if (!mounted) return; // <<< QUAN TRỌNG

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        assets = data['result'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  } catch (e) {
    if (!mounted) return;
    print("Error: $e");
    setState(() => isLoading = false);
  }
}

  Color statusColor(String status) {
    switch (status) {
      case "Online":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final item = assets[index];

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.memory),
            title: Text(item['idShort'] ?? "No name"),
            subtitle: Text(item['id']),
            trailing: Chip(
              label: const Text("Online"),
              backgroundColor: statusColor("Online"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetDetailScreen(
                    aasId: item['id'],        // ID thật cho API
                    name: item['idShort'],   // Tên hiển thị
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
