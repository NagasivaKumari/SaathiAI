import 'package:flutter/material.dart';
import '../../core/services/address_service.dart';
import 'address_edit_screen.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  late Future<List<dynamic>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _addressesFuture = AddressService.getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Address Book')),
      body: FutureBuilder<List<dynamic>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return Center(child: Text('No addresses found. Add one!'));
          }
          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, idx) {
              final addr = addresses[idx];
              final isDefault = addr['is_default'] == true;
              return ListTile(
                title: Text('${addr['street']}, ${addr['city']}'),
                subtitle: Text('${addr['state']} ${addr['zipcode']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDefault) Icon(Icons.star, color: Colors.amber),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await AddressService.deleteAddress(addr['id']);
                          _loadAddresses();
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddressEditScreen(address: addr),
                    ),
                  );
                  _loadAddresses();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddressEditScreen()),
          );
          _loadAddresses();
        },
        tooltip: 'Add Address',
        child: Icon(Icons.add),
      ),
    );
  }
}
