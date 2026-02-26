import 'package:flutter/material.dart';

class GovtSchemesScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF6F8F6),
			appBar: AppBar(
				backgroundColor: Colors.white,
				elevation: 0,
				title: Text(
					'Available Schemes',
					style: TextStyle(
						color: Color(0xFF131711),
						fontWeight: FontWeight.bold,
						fontSize: 20,
						fontFamily: 'Lexend',
					),
				),
				centerTitle: true,
				leading: IconButton(
					icon: Icon(Icons.arrow_back_ios, color: Color(0xFF131711)),
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
						// SearchBar
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
							child: TextField(
								decoration: InputDecoration(
									prefixIcon: Icon(Icons.search, color: Color(0xFF6C8764)),
									hintText: 'Search schemes (e.g. PM-Kisan)',
									filled: true,
									fillColor: Colors.white,
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(16),
										borderSide: BorderSide.none,
									),
								),
							),
						),
						// Location Filter
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
							child: Container(
								decoration: BoxDecoration(
									color: Color(0x1A4CDF20),
									borderRadius: BorderRadius.circular(24),
								),
								padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
								child: Row(
									children: [
										Icon(Icons.location_on, color: Color(0xFF4CDF20)),
										SizedBox(width: 4),
										Text('Showing schemes for Bihar', style: TextStyle(color: Color(0xFF131711), fontSize: 14)),
										SizedBox(width: 4),
										Icon(Icons.edit, color: Color(0xFF4CDF20), size: 18),
									],
								),
							),
						),
						// Chips
						Container(
							height: 48,
							padding: EdgeInsets.symmetric(horizontal: 16),
							child: ListView(
								scrollDirection: Axis.horizontal,
								children: [
									_Chip(label: 'All', selected: true, icon: Icons.expand_more),
									_Chip(label: 'Agriculture', icon: Icons.agriculture),
									_Chip(label: 'Skill Dev', icon: Icons.school),
									_Chip(label: 'Health', icon: Icons.medical_services),
								],
							),
						),
						// SectionHeader
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
											fontSize: 18,
											fontFamily: 'Lexend',
										),
									),
									Text('See all', style: TextStyle(color: Color(0xFF4CDF20), fontWeight: FontWeight.w500)),
								],
							),
						),
						// Cards Container
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Column(
								children: [
									_SchemeCard(
										imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCrnIQVKxJWSrbhW5k2slEPqm7h0XfBqM8gRzSBAtXLmnujuKZXbm-iHBWnMOEayE4CmgI0fPRyICCTgBXPCAFJtuHF_JieOWYVQUjKETnIVrHuav6VFm5rEwb92Hso6Cq3SsklKnSys-RswsJDWkTy-iNcLnBe2qHi7lXrBBFVbdyCACsOIXPZCRJ7Z6ysVfXC8w4leH3elThVWfzfHd8jgL3iJzc0sOEroB4Qgh3OPIQWG2yYBg4t4_oaBVzVtsyLVOb_0GnDUdE',
										category: 'Agriculture',
										title: 'PM-Kisan Samman Nidhi',
										description: '₹6,000 direct benefit per year',
										eligibility: 'All landholding farmers',
									),
									SizedBox(height: 20),
									_SchemeCard(
										imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCZAHOPBpvUOUdz8CIdSuag8bJ367wqIHq4rnwh3INBFblV5gfAh_8XHOpL8saI9dkEkAkUT_xXbZYmGOmcaHdgpMC5ASyZyBzVRFERTyKfSCpVB3wtSd6uxjfga7y8p_7dfS6T0p0o0vlho4ylIv8rJw_GG_cPGzbPoTaUVsdyu2xD-TOVGRncWJwySjfQjtYobSrYqQxwun2-ahJjmTmI_Hex4uNPCaw5zt4RoNHwz_AyWI-gVxGsyTnoxxxncX9QLEop92xLLbY',
										category: 'Welfare',
										title: 'PM Ujjwala Yojana',
										description: 'Free LPG connection & refilling',
										eligibility: 'Adult women of BPL household',
									),
									SizedBox(height: 20),
									_SchemeCard(
										imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtmF6bNeZdpCqL3W96iN0ip-Dl6vnmUyUtnmsuLel4kUyvkSSzmuN2iHHaiYCpDRaAhwQX0IQbArmx3HPL3PrJhT4CY4lJLbDA8CRfDZyvquKfDCnXP-lRGrIj0O820WaTII3kXpwQtIm3c0VI_zW_JVMEWjnLYs14Vvl91i5vl0hVcpr1VdCLg4xqB915tWEmO9M23rD6IHw-SBdicLbuju9nGgqts-dg59AhymC3tVWIO-y1QVyKpY3LXvRtzbjCiytoWcyDl98',
										category: 'Skills',
										title: 'Kaushal Vikas Yojana',
										description: 'Free vocational training & certification',
										eligibility: 'Unemployed youth',
									),
								],
							),
						),
						SizedBox(height: 32),
					],
				),
			),
			floatingActionButton: _VoiceButton(),
			bottomNavigationBar: _BottomTabBar(),
			floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
		);
	}
}

class _Chip extends StatelessWidget {
	final String label;
	final bool selected;
	final IconData? icon;
	const _Chip({required this.label, this.selected = false, this.icon});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(right: 8.0),
			child: ChoiceChip(
				label: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						if (icon != null) Icon(icon, size: 16, color: selected ? Colors.white : Color(0xFF131711)),
						if (icon != null) SizedBox(width: 4),
						Text(label),
					],
				),
				selected: selected,
				selectedColor: Color(0xFF4CDF20),
				backgroundColor: Colors.white,
				labelStyle: TextStyle(
					color: selected ? Colors.white : Color(0xFF131711),
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
	final String eligibility;

	const _SchemeCard({
		required this.imageUrl,
		required this.category,
		required this.title,
		required this.description,
		required this.eligibility,
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
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text(category, style: TextStyle(color: Color(0xFF4CDF20), fontWeight: FontWeight.bold, fontSize: 12)),
										Text(eligibility, style: TextStyle(color: Color(0xFF6C8764), fontSize: 12)),
									],
								),
								SizedBox(height: 4),
								Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Lexend', color: Color(0xFF131711))),
								SizedBox(height: 8),
								Text(description, style: TextStyle(color: Color(0xFF6C8764), fontSize: 14)),
								SizedBox(height: 12),
								ElevatedButton.icon(
									style: ElevatedButton.styleFrom(
										backgroundColor: Color(0xFF4CDF20),
										foregroundColor: Color(0xFF131711),
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
									),
									icon: Icon(Icons.mic),
									label: Text('Speak to Sathi'),
									onPressed: () {},
								),
							],
						),
					),
				],
			),
		);
	}
}

class _VoiceButton extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return FloatingActionButton(
			onPressed: () {},
			backgroundColor: Color(0xFF131711),
			child: Icon(Icons.mic, color: Color(0xFF4CDF20), size: 32),
			elevation: 8,
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
								Icon(Icons.home, color: Colors.grey),
								Text('Home', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
							],
						),
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.description, color: Color(0xFF4CDF20)),
								Text('Schemes', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4CDF20))),
							],
						),
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.storefront, color: Colors.grey),
								Text('Market', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
							],
						),
						Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.work, color: Colors.grey),
								Text('Skills', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
							],
						),
					],
				),
			),
		);
	}
}