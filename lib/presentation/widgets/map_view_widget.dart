import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapViewWidget extends StatelessWidget {
  final double height;

  const MapViewWidget({super.key, this.height = 250.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: MapLibreMap(
        styleString: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
        initialCameraPosition: const CameraPosition(
          target: LatLng(31.7683, 35.2137), // Israel center approx
          zoom: 7.0,
        ),
        myLocationEnabled: true,
      ),
    );
  }
}
