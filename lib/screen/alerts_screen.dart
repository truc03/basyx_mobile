import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'alert_detail.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    final res = await http.get(Uri.parse("http://192.168.1.10:8081/shells"));
    final data = json.decode(res.body);
    final shells = data['result'] ?? [];

    List temp = [];

    for (var shell in shells) {
      final assetName = shell['idShort'] ?? "Unknown";
      final submodels = shell['submodels'] ?? [];

      for (var sm in submodels) {
        final smId = sm['keys']?[0]?['value'];
        if (smId == null) continue;

        String level = "Info";
        if (smId.toString().contains("Technical")) level = "Warning";
        if (smId.toString().contains("Relationship")) level = "Error";

        temp.add({
          "asset": assetName,
          "submodelUrl": smId.toString(), // ID gốc để encode bên detail
          "title": smId.toString().split('/').last,
          "level": level,
          "time": DateTime.now().toString().substring(11, 16),
        });
      }
    }

    setState(() {
      alerts = temp;
      isLoading = false;
    });
  }

  Color levelColor(String level) {
    switch (level) {
      case "Error":
        return Colors.red;
      case "Warning":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, i) {
        final a = alerts[i];

        return Card(
          child: ListTile(
            leading: Icon(Icons.notifications, color: levelColor(a["level"])),
            title: Text(a["title"]),
            subtitle: Text("${a["asset"]} • ${a["time"]}"),
            trailing: Chip(
              label: Text(a["level"]),
              backgroundColor: levelColor(a["level"]).withOpacity(0.15),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertDetailScreen(
                    submodelApiUrl: a["submodelUrl"],
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
