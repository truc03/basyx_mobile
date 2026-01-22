import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssetDetailScreen extends StatefulWidget {
  final String aasId;
  final String name;

  const AssetDetailScreen({
    super.key,
    required this.aasId,
    required this.name,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  List submodels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmodels();
  }
Future<void> fetchSubmodels() async {
  try {
    final url = Uri.parse("http://192.168.1.10:8081/shells");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final aas = data['result'][0];       // lấy AAS đầu tiên
      final smList = aas['submodels'];     // lấy submodels trong nó

      if (!mounted) return;
      setState(() {
        submodels = smList;
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("Error: $e");
    if (mounted) setState(() => isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: submodels.length,
              itemBuilder: (context, index) {
                final sm = submodels[index];
                final smId = sm['keys'][0]['value'];

                return ListTile(
                  leading: const Icon(Icons.layers),
                  title: Text(smId.split('/').last),
                  subtitle: Text(smId),
                );
              },
            ),
    );
  }
}
