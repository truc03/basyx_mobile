import 'package:flutter/material.dart';
import '../widget/status_card.dart';
import '../service/aas_service.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: AasService.fetchDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Không tải được dữ liệu Dashboard"));
        }

        final stats = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              StatusCard(
                title: "Assets",
                value: (stats["assets"] ?? 0).toString(),
                icon: Icons.devices,
                color: Colors.blue,
                onTap: () => onTabChange(1),
              ),
              StatusCard(
                title: "Online",
                value: (stats["online"] ?? 0).toString(),
                icon: Icons.wifi,
                color: Colors.green,
                onTap: () => onTabChange(2),
              ),
              StatusCard(
                title: "Warning",
                value: (stats["warning"] ?? 0).toString(),
                icon: Icons.warning,
                color: Colors.orange,
              ),
              StatusCard(
                title: "Error",
                value: (stats["error"] ?? 0).toString(),
                icon: Icons.error,
                color: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
}
