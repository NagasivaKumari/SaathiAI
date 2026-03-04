import 'package:flutter/material.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> schemes = [
      {
        'name': 'PM Kisan Samman Nidhi',
        'desc': '₹6000/year for eligible farmers',
        'status': 'Active',
        'color': Colors.green.shade100,
        'icon': Icons.agriculture,
      },
      {
        'name': 'PM Awas Yojana',
        'desc': 'Subsidy for rural housing',
        'status': 'Apply Soon',
        'color': Colors.yellow.shade100,
        'icon': Icons.home,
      },
      {
        'name': 'PM Fasal Bima Yojana',
        'desc': 'Crop insurance scheme',
        'status': 'Inactive',
        'color': Colors.red.shade100,
        'icon': Icons.grass,
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Schemes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discover Government Schemes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: schemes.length,
                separatorBuilder: (context, idx) => SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final scheme = schemes[idx];
                  return Card(
                    color: scheme['color'],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(scheme['icon'], color: Colors.green, size: 36),
                      title: Text(scheme['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(scheme['desc']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(scheme['status'],
                              style: TextStyle(
                                color: scheme['status'] == 'Active'
                                    ? Colors.green
                                    : scheme['status'] == 'Apply Soon'
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              )),
                          if (scheme['status'] == 'Active')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(80, 32),
                              ),
                              onPressed: () {},
                              child: Text('View'),
                            )
                          else if (scheme['status'] == 'Apply Soon')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: Size(80, 32),
                              ),
                              onPressed: () {},
                              child: Text('Notify Me'),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                minimumSize: Size(80, 32),
                              ),
                              onPressed: null,
                              child: Text('Closed'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
