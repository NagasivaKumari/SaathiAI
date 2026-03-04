import 'package:flutter/material.dart';

class SchemeDiscoveryScreen extends StatelessWidget {
  const SchemeDiscoveryScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF6F8F6),
			appBar: AppBar(
				backgroundColor: const Color(0xFFF6F8F6),
				elevation: 0,
				title: Text(
					'Scheme Discovery',
					style: TextStyle(
						color: Color(0xFF131711),
						fontWeight: FontWeight.bold,
						fontSize: 20,
						fontFamily: 'Lexend',
					),
				),
				centerTitle: true,
				leading: IconButton(
					icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF131711)),
					onPressed: () {},
				),
				actions: [
					IconButton(
						icon: Icon(Icons.account_circle, color: Color(0xFF4CDF20)),
						onPressed: () {},
					),
				],
			),
			body: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Search and Location Filters
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									TextField(
										decoration: InputDecoration(
											prefixIcon: Icon(Icons.search, color: Color(0xFF6C8764)),
											hintText: 'Search schemes like PM-Kisan',
											filled: true,
											fillColor: Colors.white,
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(16),
												borderSide: BorderSide.none,
											),
										),
									),
									SizedBox(height: 12),
									Row(
										children: [
											Icon(Icons.location_on, color: Color(0xFF4CDF20)),
											SizedBox(width: 4),
											Text('Showing schemes for ', style: TextStyle(color: Color(0xFF6C8764), fontSize: 14)),
											Text('Madhya Pradesh', style: TextStyle(color: Color(0xFF131711), fontSize: 14, decoration: TextDecoration.underline)),
										],
									),
								],
							),
						),
						// Filter Chips
						Container(
							height: 48,
							padding: EdgeInsets.symmetric(horizontal: 16),
							child: ListView(
								scrollDirection: Axis.horizontal,
								children: [
									_FilterChip(label: 'All Schemes', selected: true),
									_FilterChip(label: 'Agriculture'),
									_FilterChip(label: 'Education'),
									_FilterChip(label: 'Health'),
								],
							),
						),
						// Recommended Section
						Padding(
							padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Text(
										'Recommended for You',
										style: TextStyle(
											color: Color(0xFF131711),
											fontWeight: FontWeight.bold,
											fontSize: 20,
											fontFamily: 'Lexend',
										),
									),
									Text('View All', style: TextStyle(color: Color(0xFF4CDF20), fontWeight: FontWeight.w500)),
								],
							),
						),
						// Scheme Cards
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Column(
								children: [
									_SchemeCard(
										imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBPpOf57TkLDkv-AvJ-VPFGIQv7mXyDTqVD9DvWVNustwp9_POH3QVdlJNinsKL79QU5caa_MKES0jhFWdoxauGfy1B-7H3anucoGtMDFW1FUQ15lFMNkkaF_kX4UKuP302-dQvPtIB0xWB-ka_deMdMyeBnmPdRQ2hmTrMbunStvXKYwXPxlw6XEYW_Q8avIMhoh_x14bHm3UqXY62UIoxY1rpshZG3AlT929yXFUBTAjOpl_ErYokoQlmLClZ3PfOvbWhQrn4UFQ',
										category: 'Agriculture',
										title: 'PM-Kisan Samman Nidhi',
										description: '₹6,000 yearly direct income support for small and marginal farmers.',
										tags: ['Landholder', 'Ongoing'],
									),
									SizedBox(height: 20),
									_SchemeCard(
										imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAksJ9tPAOeZMCq_bF1mfjfqkL7MMtWdchgd-tdbXEnSuyDYz9zeivF3K3pgTsDtkDctQG3dqH_IyGQn1cdnQQWKdmCKHGMG2vdnc6Wk66pSPwzrBiaYusg_mBv9IZPph4OhPgvcqG_Bzxy5RgNcElgmbRcjH74Rmtye9hXvgmYzFst3eMNN9IN0Bsy2M5naTqHLjm5ryCYxKBQcgX-j8h_KPs6_3PXDpUTJA8fKhteV_SyvNfPHXzvGOOVZokebsuATuz2y1nCQL4',
										category: 'Health',
										title: 'Ayushman Bharat (PM-JAY)',
										description: 'Free health cover up to ₹5 Lakhs per family per year for secondary/tertiary care.',
										tags: ['BPL Families'],
									),
								],
							),
						),
						SizedBox(height: 32),
					],
				),
			),
			floatingActionButton: _ChatButton(),
			bottomNavigationBar: _BottomTabBar(),
			floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
		);
	}
}

class _FilterChip extends StatelessWidget {
	final String label;
	final bool selected;
	const _FilterChip({required this.label, this.selected = false});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(right: 8.0),
			child: ChoiceChip(
				label: Text(label),
				selected: selected,
				selectedColor: Color(0xFF4CDF20),
				backgroundColor: Colors.white,
				labelStyle: TextStyle(
					color: selected ? Color(0xFF131711) : Color(0xFF131711),
					fontWeight: FontWeight.w600,
				),
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
				onSelected: (_) {},
			),
		);
	}
}

class _SchemeCard extends StatelessWidget {
	final String imageUrl;
	final String category;
	final String title;
	final String description;
	final List<String> tags;

	const _SchemeCard({
		required this.imageUrl,
		required this.category,
		required this.title,
		required this.description,
		required this.tags,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			elevation: 4,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ClipRRect(
						borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
						child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
					),
					Padding(
						padding: const EdgeInsets.all(16.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(category.toUpperCase(), style: TextStyle(color: Color(0xFF4CDF20), fontWeight: FontWeight.bold, fontSize: 12)),
								SizedBox(height: 4),
								Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Lexend', color: Color(0xFF131711))),
								SizedBox(height: 8),
								Text(description, style: TextStyle(color: Color(0xFF6C8764), fontSize: 14)),
								SizedBox(height: 8),
								Wrap(
									spacing: 8,
									children: tags.map((tag) => Chip(label: Text(tag))).toList(),
								),
								SizedBox(height: 12),
								Row(
									children: [
										Expanded(
											child: ElevatedButton.icon(
												style: ElevatedButton.styleFrom(
													backgroundColor: Color(0xFF4CDF20),
													foregroundColor: Color(0xFF131711),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
												),
												icon: Icon(Icons.mic),
												label: Text('Speak to Sathi'),
												onPressed: () {},
											),
										),
										SizedBox(width: 8),
										IconButton(
											icon: Icon(Icons.info, color: Color(0xFF4CDF20)),
											onPressed: () {},
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
}

class _ChatButton extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return FloatingActionButton(
			onPressed: () {},
			backgroundColor: Color(0xFF131711),
			elevation: 8,
			child: Icon(Icons.chat_bubble_outline, color: Color(0xFF4CDF20), size: 32),
		);
	}
}

class _BottomTabBar extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return BottomAppBar(
			shape: CircularNotchedRectangle(),
			notchMargin: 8,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceAround,
					children: [
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.home, color: Color(0xFF4CDF20)),
								Text('Home', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4CDF20))),
							],
						),
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.explore, color: Color(0xFF6C8764)),
								Text('Market', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF6C8764))),
							],
						),
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.school, color: Color(0xFF6C8764)),
								Text('Skills', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF6C8764))),
							],
						),
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.person, color: Color(0xFF6C8764)),
								Text('Profile', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF6C8764))),
							],
						),
					],
				),
			),
		);
	}
}