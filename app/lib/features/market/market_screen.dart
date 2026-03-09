import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/providers/language_provider.dart';
import '../../services/api_client.dart';
import '../voice/voice_screen.dart';

class _Design {
  static const primary = Color(0xFF4CDF20);
  static const background = Color(0xFFF6F8F6);
  static const textPrimary = Color(0xFF131711);
  static const textMuted = Color(0xFF6C8764);
  static const cardBg = Colors.white;
}

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
  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: AppConfig.BASE_URL);
    fetchMarketData();
  }

  Future<void> fetchMarketData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await api.marketPrices();
      setState(() {
        crops = List<dynamic>.from(data);
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
    final lang = context.watch<LanguageProvider>();
    String t(String key) => lang.translate(key);

    return Scaffold(
      backgroundColor: _Design.background,
      appBar: AppBar(
        backgroundColor: _Design.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _Design.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(t('market_rates'), style: const TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: _Design.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      TextButton(onPressed: fetchMarketData, child: Text(lang.translate('retry'))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchMarketData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSathiInsightCard(context, t),
                        _buildLiveCropRates(context, t),
                        _buildNearbyMandis(context, t),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSathiInsightCard(BuildContext context, String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _Design.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Design.primary.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              color: _Design.primary.withOpacity(0.15),
              child: const Center(child: Icon(Icons.psychology, size: 56, color: _Design.primary)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: _Design.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(t('sathi_ai_insight'), style: const TextStyle(color: _Design.primary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(t('hold_tomato_advice'), style: const TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(t('sathi_insight_description'), style: const TextStyle(color: _Design.textMuted, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Design.primary,
                        foregroundColor: _Design.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 2,
                      ),
                      child: Text(t('full_market_forecast')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCropRates(BuildContext context, String Function(String) t) {
    final list = crops.isEmpty
        ? [
            {'crop': 'Tomato', 'price': '2450', 'trend': 'up', 'change': '120'},
            {'crop': 'Wheat', 'price': '2125', 'trend': 'down', 'change': '15'},
            {'crop': 'Rice (Basmati)', 'price': '3800', 'trend': 'up', 'change': '45'},
          ]
        : crops.map((c) {
            final crop = c is Map ? c as Map<String, dynamic> : <String, dynamic>{};
            return {
              'crop': crop['crop'] ?? crop['name'] ?? 'Crop',
              'price': (crop['price'] ?? crop['rate'] ?? '0').toString(),
              'trend': (crop['trend'] ?? 'up').toString().toLowerCase(),
              'change': (crop['change'] ?? crop['changeAmount'] ?? '0').toString(),
            };
          }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('live_crop_rates'), style: const TextStyle(color: _Design.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _Design.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(t('today'), style: const TextStyle(color: _Design.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...list.asMap().entries.map((e) {
            final Map<String, dynamic> item = e.value;
            final cropName = (item['crop'] ?? 'Crop').toString();
            final price = (item['price'] ?? '0').toString();
            final trend = (item['trend'] ?? 'up').toString();
            final change = (item['change'] ?? '0').toString();
            IconData icon = Icons.agriculture;
            if (cropName.toLowerCase().contains('tomato')) {
              icon = Icons.local_florist;
            } else if (cropName.toLowerCase().contains('wheat')) icon = Icons.grass;
            else if (cropName.toLowerCase().contains('rice')) icon = Icons.eco;
            final isUp = trend == 'up';
            final trendColor = isUp ? _Design.primary : Colors.red;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _Design.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: trendColor, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cropName, style: const TextStyle(color: _Design.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(t('per_quintal'), style: const TextStyle(color: _Design.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹$price', style: const TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 16, color: trendColor),
                            const SizedBox(width: 4),
                            Text('${isUp ? '+' : '-'}₹$change', style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNearbyMandis(BuildContext context, String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('nearby_mandis'), style: const TextStyle(color: _Design.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _Design.primary.withOpacity(0.12),
                ),
                child: const Center(child: Icon(Icons.map_outlined, size: 48, color: _Design.primary)),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _Design.cardBg.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('closest_market'), style: const TextStyle(color: _Design.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            const Text('Azamgarh Main Mandi', style: TextStyle(color: _Design.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('2.4 km away • Open until 6:00 PM', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.directions, color: _Design.primary),
                        style: IconButton.styleFrom(backgroundColor: _Design.primary.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
