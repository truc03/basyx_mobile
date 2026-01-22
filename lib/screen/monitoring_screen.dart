import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../service/Aas_service.dart'; // Đảm bảo đường dẫn này đúng với dự án của bạn

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  List<FlSpot> spots = [];
  Timer? timer;
  int timeIndex = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Gọi dữ liệu ngay lập tức khi vào màn hình
    _initialFetch();
    // Thiết lập cập nhật định kỳ mỗi 5 giây
    startRealtime();
  }

  /// Hàm lấy dữ liệu lần đầu tiên
  Future<void> _initialFetch() async {
    try {
      final temp = await AasService.fetchLiveTemperature();
      
      if (!mounted) return;

      setState(() {
        isLoading = false; // Tắt trạng thái loading sau khi có phản hồi
        if (temp != null) {
          spots.add(FlSpot(timeIndex.toDouble(), temp));
          timeIndex++;
          errorMessage = null;
        } else {
          errorMessage = "Không tìm thấy dữ liệu trên Server.";
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Lỗi kết nối: $e";
        });
      }
    }
  }

  /// Hàm cập nhật dữ liệu thời gian thực
  void startRealtime() {
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final temp = await AasService.fetchLiveTemperature();
      
      if (!mounted) return;

      setState(() {
        // Luôn đảm bảo isLoading tắt nếu timer chạy
        if (isLoading) isLoading = false;

        if (temp != null) {
          spots.add(FlSpot(timeIndex.toDouble(), temp));
          // Giữ lại tối đa 20 điểm dữ liệu trên biểu đồ để tránh lag
          if (spots.length > 20) spots.removeAt(0);
          timeIndex++;
          errorMessage = null;
        } else {
          // Chỉ báo lỗi nếu danh sách đang trống (mất kết nối hoàn toàn)
          if (spots.isEmpty) errorMessage = "Mất kết nối dữ liệu từ Server.";
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Quan trọng: Phải hủy timer khi thoát màn hình để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitor AAS Realtime"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hiển thị lỗi màu đỏ nếu có
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : spots.isEmpty && errorMessage != null
                      ? _buildEmptyState()
                      : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện khi không có dữ liệu
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Đang đợi dữ liệu từ Server BaSyx...", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() => isLoading = true);
              _initialFetch();
            },
            child: const Text("Thử lại"),
          )
        ],
      ),
    );
  }

  /// Giao diện biểu đồ đường
  Widget _buildChart() {
    return LineChart(
      LineChartData(
        minY: 0, // Điều chỉnh minY, maxY tùy theo dải nhiệt độ thực tế của bạn
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}