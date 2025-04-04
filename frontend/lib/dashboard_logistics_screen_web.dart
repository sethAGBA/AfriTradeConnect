import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardLogisticsScreenWeb extends StatefulWidget {
  @override
  _DashboardLogisticsScreenWebState createState() => _DashboardLogisticsScreenWebState();
}

class _DashboardLogisticsScreenWebState extends State<DashboardLogisticsScreenWeb> {
  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 15.2993, longitude: 38.9319), // Eritrea
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AfriTrade Connect'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(onPressed: () {}, child: Text('Explore', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () {}, child: Text('Dashboard', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () {}, child: Text('Logistics', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () {}, child: Text('Payments', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In Transit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text('Honey Ship 12264588790'),
                          SizedBox(height: 8),
                          Text('Eritrea → Kenya'),
                          SizedBox(height: 16),
                          Container(
                            height: 200,
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
                                  await controller.addMarker(GeoPoint(latitude: 15.2993, longitude: 38.9319)); // Eritrea
                                  await controller.addMarker(GeoPoint(latitude: -1.2921, longitude: 36.8219)); // Kenya
                                  await controller.drawRoad(
                                    GeoPoint(latitude: 15.2993, longitude: 38.9319),
                                    GeoPoint(latitude: -1.2921, longitude: 36.8219),
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
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credit Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: CircularProgressIndicator(
                                  value: 680 / 1000,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              ),
                              Text('680', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Credit History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Container(
                            height: 100,
                            child: LineChart(
                              LineChartData(
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.toInt()) {
                                          case 0:
                                            return Text('Jan');
                                          case 1:
                                            return Text('Feb');
                                          case 2:
                                            return Text('Mar');
                                          default:
                                            return Text('');
                                        }
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      FlSpot(0, 600),
                                      FlSpot(1, 650),
                                      FlSpot(2, 680),
                                    ],
                                    isCurved: true,
                                    color: Colors.blue,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text('Access a e-voucher', style: TextStyle(color: Colors.grey)),
                          Text('Review the checklist', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('25 mins ago', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}