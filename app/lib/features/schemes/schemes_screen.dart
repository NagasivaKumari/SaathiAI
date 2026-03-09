import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/providers/language_provider.dart';
import '../../services/api_client.dart';
import '../voice/voice_screen.dart';
import 'scheme_detail_screen.dart';

class _Design {
  static const primary = Color(0xFF4CDF20);
  static const background = Color(0xFFF6F8F6);
  static const textPrimary = Color(0xFF131711);
  static const textMuted = Color(0xFF6C8764);
  static const cardBg = Colors.white;
  static const borderLight = Color(0x08131711);
}

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  List<dynamic> schemes = [];
  bool loading = true;
  String? error;
  String searchQuery = '';
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  late final ApiClient api;

  static const List<String> categories = ['All', 'Agriculture', 'Education', 'Health'];

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: AppConfig.BASE_URL);
    fetchSchemes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSchemes() async {
    setState(() { loading = true; error = null; });
    try {
      schemes = await api.getSchemes();
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  List<dynamic> get _filteredSchemes {
    var list = schemes;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((s) =>
        (s['name'] ?? '').toString().toLowerCase().contains(q) ||
        (s['description'] ?? '').toString().toLowerCase().contains(q) ||
        (s['category'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
    if (selectedCategory != 'All') {
      list = list.where((s) =>
        (s['category'] ?? 'Agriculture').toString() == selectedCategory).toList();
    }
    return list;
  }

  String _categoryForScheme(dynamic scheme) {
    final name = (scheme['name'] ?? '').toString();
    final cat = (scheme['category'] ?? '').toString();
    if (cat.isNotEmpty) return cat;
    if (name.contains('Kisan') || name.contains('PM-Kisan')) return 'Agriculture';
    if (name.contains('Awas') || name.contains('Housing')) return 'Agriculture';
    if (name.contains('JAY') || name.contains('Health') || name.contains('Ayushman')) return 'Health';
    if (name.contains('Education') || name.contains('Scholarship')) return 'Education';
    return 'Agriculture';
  }

  String _tagLabel(dynamic scheme) {
    final status = (scheme['status'] ?? 'Active').toString();
    if (status == 'Active') return 'Ongoing';
    if (status == 'Apply Soon') return 'Apply Soon';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    String t(String key) => lang.translate(key);

    if (loading) {
      return Scaffold(
        backgroundColor: _Design.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        backgroundColor: _Design.background,
        appBar: _appBar(context, t),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t('network_error'), style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              TextButton(onPressed: fetchSchemes, child: Text(t('retry'))),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredSchemes;
    return Scaffold(
      backgroundColor: _Design.background,
      appBar: _appBar(context, t),
      body: RefreshIndicator(
        onRefresh: fetchSchemes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(t),
              _buildLocationRow(t),
              _buildFilterChips(t),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t('recommended_for_you'),
                        style: const TextStyle(color: _Design.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {},
                      child: Text(t('view_all'), style: const TextStyle(color: _Design.primary, fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('${t('no_schemes_for')} "${searchQuery.isEmpty ? selectedCategory : searchQuery}"')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, idx) => _buildSchemeCard(context, t, filtered[idx]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, String Function(String) t) {
    return AppBar(
      backgroundColor: _Design.cardBg,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: _Design.textPrimary), onPressed: () => Navigator.maybePop(context)),
      title: Text(t('scheme_discovery'), style: const TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: _Design.textPrimary),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  Widget _buildSearchBar(String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: t('search_schemes_placeholder'),
          hintStyle: const TextStyle(color: _Design.textMuted),
          prefixIcon: const Icon(Icons.search, color: _Design.textMuted),
          filled: true,
          fillColor: _Design.cardBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: _Design.primary, size: 20),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              text: '${t('showing_schemes_for')} ',
              style: const TextStyle(color: _Design.textMuted, fontSize: 14),
              children: [
                TextSpan(text: 'Madhya Pradesh', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? _Design.primary : _Design.textPrimary, decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(String Function(String) t) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          final label = cat == 'All' ? t('all_schemes') : t(cat.toLowerCase());
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => selectedCategory = cat),
              backgroundColor: _Design.cardBg,
              selectedColor: _Design.primary,
              checkmarkColor: _Design.textPrimary,
              labelStyle: TextStyle(
                color: isSelected ? _Design.textPrimary : _Design.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(color: _Design.borderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, String Function(String) t, dynamic scheme) {
    final category = _categoryForScheme(scheme);
    final name = scheme['name'] ?? '';
    final description = scheme['description'] ?? '';
    final id = scheme['id']?.toString() ?? '';
    final imageUrl = scheme['image_url'] as String?;
    final isTop = (scheme['featured'] == true) || (name.toString().toLowerCase().contains('kisan') && category == 'Agriculture');

    return Container(
      decoration: BoxDecoration(
        color: _Design.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Design.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholderImage())
                    : _placeholderImage(),
              ),
              if (isTop)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _Design.primary, borderRadius: BorderRadius.circular(20)),
                    child: Text(t('top_choice'), style: const TextStyle(color: _Design.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category, style: const TextStyle(color: _Design.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(name, style: const TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border, color: _Design.textMuted),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: _Design.textMuted, fontSize: 14, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _tagChip(Icons.verified, _tagLabel(scheme), Colors.blue),
                    if ((scheme['status'] ?? 'Active') == 'Active') _tagChip(Icons.event, 'Ongoing', Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceScreen())),
                        icon: const Icon(Icons.mic, size: 20),
                        label: Text(t('speak_to_sathi')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Design.primary,
                          foregroundColor: _Design.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 2,
                          shadowColor: _Design.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SchemeDetailScreen(schemeId: id))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _Design.primary),
                          foregroundColor: _Design.primary,
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(Icons.info_outline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: _Design.primary.withOpacity(0.15),
      child: const Center(child: Icon(Icons.agriculture, size: 48, color: _Design.primary)),
    );
  }

  Widget _tagChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500))],
      ),
    );
  }
}
