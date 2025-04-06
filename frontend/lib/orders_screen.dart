import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './widgets/config.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 5.6148, longitude: -0.2057), // Amiel
  );

  Map<String, dynamic>? orderData; // Données de la commande

  @override
  void initState() {
    super.initState();
    loadOrderData(); // Charger les données au démarrage
  }

  Future<void> loadOrderData() async {
    var box = await Hive.openBox('orders');
    if (await Config.isOffline()) {
      setState(() {
        orderData = box.get('order_123456', defaultValue: {
          'id': '123456',
          'status': 'In-Transit',
          'from': 'Lagos, Nigeria',
          'to': 'Amiel, Ghana',
          'product': 'Cotton Fabric',
          'quantity': '100 cals',
          'history': [
            {'event': 'Order placed', 'date': 'Apr 12', 'location': 'Lagos, Nigeria'},
            {'event': 'Order shipped', 'date': 'Apr 12', 'location': 'Lagos, Nigeria'},
          ],
        });
      });
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('${Config.shipmentsUrl}/orders/123456'), headers: Config.authHeaders)
          .timeout(Config.timeoutDuration);
      if (response.statusCode == 200) {
        orderData = jsonDecode(response.body);
        box.put('order_123456', orderData);
        setState(() {});
      } else {
        setState(() {
          orderData = box.get('order_123456'); // Charger depuis le cache en cas d'échec
        });
      }
    } catch (e) {
      setState(() {
        orderData = box.get('order_123456'); // Charger depuis le cache en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Colors.blue,
      ),
      body: orderData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${orderData!['id']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Apr 18 - Apr 21'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('In-Transit: ${orderData!['product']}'),
                          Text('In Quantity: ${orderData!['quantity']}'),
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
                        Text('Optimize Cost',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Use shipment consolidation (Amiel apolis)'),
                        SizedBox(height: 16),
                        Text('Tracking History',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ...(orderData!['history'] as List).map((event) {
                          return TimelineTile(
                            alignment: TimelineAlign.start,
                            isFirst: event == orderData!['history'].first,
                            isLast: event == orderData!['history'].last,
                            indicatorStyle: const IndicatorStyle(color: Colors.blue),
                            endChild: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  '${event['event']}\n${event['date']}\nFund up: ${event['location']}'),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    Hive.close(); // Fermer Hive proprement
    super.dispose();
  }
}