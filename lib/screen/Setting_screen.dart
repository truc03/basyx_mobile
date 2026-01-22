import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  String currentIp = "";

  @override
  void initState() {
    super.initState();
    loadIp();
  }

  Future<void> loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentIp = prefs.getString('basyx_ip') ?? "192.168.1.10";
      _ipController.text = currentIp;
    });
  }

  Future<void> saveIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('basyx_ip', _ipController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu IP Server")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BaSyx Server",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "IP Address",
                hintText: "VD: 192.168.1.10:8081",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: saveIp,
              icon: const Icon(Icons.save),
              label: const Text("Lưu cấu hình"),
            ),
            const Divider(height: 32),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("Digital Twin Monitoring App"),
              subtitle: Text("Version 1.0 - Internship Project"),
            ),
          ],
        ),
      ),
    );
  }
}
