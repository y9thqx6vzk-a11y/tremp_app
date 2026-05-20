import 'package:flutter/material.dart';

class MapboxPlaceholder extends StatelessWidget {
  final double height;

  const MapboxPlaceholder({super.key, this.height = 250.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey[100]!, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background grid pattern simulation
          Opacity(
            opacity: 0.1,
            child: GridPaper(
              color: Colors.blueGrey[800]!,
              divisions: 2,
              subdivisions: 2,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_rounded, size: 48, color: Colors.blueGrey[300]),
              const SizedBox(height: 12),
              Text(
                'Mapbox Infrastructure Ready',
                style: TextStyle(
                  color: Colors.blueGrey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'המפה תיטען כאן לאחר הפעלת מפתח ה-API',
                style: TextStyle(
                  color: Colors.blueGrey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
