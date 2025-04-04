import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/config.dart';

class DashboardScreenWeb extends StatefulWidget {
  @override
  _DashboardScreenWebState createState() => _DashboardScreenWebState();
}

class _DashboardScreenWebState extends State<DashboardScreenWeb> {
  Future<void> _logout() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    Navigator.pushReplacementNamed(context, '/login');
  }

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
          TextButton(onPressed: _logout, child: Text('Logout', style: TextStyle(color: Colors.white))),
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
                        children: [
                          Text('Sales', style: TextStyle(fontSize: 16)),
                          Text('\$12,600', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                        children: [
                          Text('Purchases', style: TextStyle(fontSize: 16)),
                          Text('\$6,200', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                        children: [
                          Text('Spending', style: TextStyle(fontSize: 16)),
                          Text('\$1,000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                        children: [
                          Text('Credit Score', style: TextStyle(fontSize: 16)),
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              value: 630 / 1000,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          Text('630', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text('Sales & Purchases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 200,
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
                        FlSpot(0, 5000),
                        FlSpot(1, 6000),
                        FlSpot(2, 4000),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 2000),
                        FlSpot(1, 3000),
                        FlSpot(2, 2500),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credit History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Support cash flow by segment', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 16),
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
                                      FlSpot(2, 630),
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
                          Text('Active at a legs', style: TextStyle(color: Colors.grey)),
                          Text('Need to pay', style: TextStyle(fontWeight: FontWeight.bold)),
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