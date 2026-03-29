import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  @override
Widget build(BuildContext context) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Thêm padding để nội dung không sát mép
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Cố gắng chiếm ít không gian nhất có thể
          children: [
            Flexible( // Dùng Flexible để Icon có thể thu nhỏ nếu thiếu chỗ
              child: Icon(icon, color: color, size: 32), // Giảm size icon xuống một chút (từ 40 -> 32)
            ),
            const SizedBox(height: 4),
            Text(
              title, 
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20, // Giảm size chữ xuống một chút (từ 22 -> 20)
                fontWeight: FontWeight.bold, 
                color: color
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}