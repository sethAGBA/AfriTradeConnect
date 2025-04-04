import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 5.6148, longitude: -0.2057), // Amiel
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #123456', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Apr 18 - Apr 21'),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('In-Transit: Cotton Fabric'),
                    Text('In Quantity: 100 cals'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: OSMFlutter(
              controller: controller,
              osmOption: const OSMOption(
                zoomOption: ZoomOption(
                  initZoom: 5,
                  minZoomLevel: 2,
                  maxZoomLevel: 18,
                  stepZoom: 1.0,
                ),
              ),
              onMapIsReady: (isReady) async {
                if (isReady) {
                  await controller.addMarker(GeoPoint(latitude: 6.5244, longitude: 3.3792)); // Lagos
                  await controller.addMarker(GeoPoint(latitude: 5.6148, longitude: -0.2057)); // Amiel
                  await controller.drawRoad(
                    GeoPoint(latitude: 6.5244, longitude: 3.3792),
                    GeoPoint(latitude: 5.6148, longitude: -0.2057),
                    roadType: RoadType.car,
                    roadOption: const RoadOption(
                      roadColor: Colors.blue,
                      roadWidth: 10,
                    ),
                  );
                }
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Optimize Cost', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Use shipment consolidation (Amiel apolis)'),
                  SizedBox(height: 16),
                  Text('Tracking History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TimelineTile(
                    alignment: TimelineAlign.start,
                    isFirst: true,
                    indicatorStyle: const IndicatorStyle(color: Colors.blue),
                    endChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Order #123456 placed\nApr 12\nFund up: Lagos, Nigeria'),
                    ),
                  ),
                  TimelineTile(
                    alignment: TimelineAlign.start,
                    isLast: true,
                    indicatorStyle: const IndicatorStyle(color: Colors.blue),
                    endChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Order #123456 shipped\nApr 12\nFund up: Lagos, Nigeria'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}