import 'package:flutter/material.dart';

class PaymentsScreenWeb extends StatelessWidget {
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
            Text('Payments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                          Text('Wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text('\$3,750', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('GHS 7,500', style: TextStyle(fontSize: 16)),
                          Text('BTC 0.012', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('Constant'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                            ],
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text('Funding Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          Text('Request Financing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$10,000', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Apply for Loan'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                          Text('Request Financing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$20,000', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Apply for Loan'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
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