import 'package:flutter/material.dart';
import '../../services/api_client.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketScreenBody();
  }
}

class MarketScreenBody extends StatefulWidget {
  const MarketScreenBody({super.key});

  @override
  State<MarketScreenBody> createState() => _MarketScreenBodyState();
}

class _MarketScreenBodyState extends State<MarketScreenBody> {
  List<dynamic> crops = [];
  bool loading = true;
  String? error;
  final ApiClient api = ApiClient(baseUrl: 'http://10.0.2.2:3000');

  @override
  void initState() {
    super.initState();
    fetchMarketData();
  }

  Future<void> fetchMarketData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // Example: fetch onion prices from backend (which now uses Agmarknet)
      final data = await api.marketPrices();
      setState(() {
        crops = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Market', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Market Prices & Advice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: crops.length,
                          separatorBuilder: (context, idx) => const SizedBox(height: 16),
                          itemBuilder: (context, idx) {
                            final crop = crops[idx];
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: Icon(
                                  (crop['trend'] ?? 'up') == 'up' ? Icons.trending_up : Icons.trending_down,
                                  color: (crop['trend'] ?? 'up') == 'up' ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                title: Text(crop['crop'] ?? crop['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Price: ₹${crop['price'] ?? ''}\nAdvice: ${(crop['advice'] ?? 'N/A')}'),
                                trailing: (crop['trend'] ?? 'up') == 'up'
                                    ? const Icon(Icons.arrow_upward, color: Colors.green)
                                    : const Icon(Icons.arrow_downward, color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: const ListTile(
                          leading: Icon(Icons.star, color: Colors.blue),
                          title: Text('Best mandi today: Indore'),
                          subtitle: Text('Highest wheat price'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
