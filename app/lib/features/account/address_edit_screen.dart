import 'package:flutter/material.dart';
import '../../core/services/address_service.dart';

class AddressEditScreen extends StatefulWidget {
  final Map<String, dynamic>? address;

  const AddressEditScreen({super.key, this.address});

  @override
  _AddressEditScreenState createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!['name'] ?? '';
      _phoneController.text = widget.address!['phone'] ?? '';
      _streetController.text = widget.address!['street'] ?? '';
      _cityController.text = widget.address!['city'] ?? '';
      _stateController.text = widget.address!['state'] ?? '';
      _zipController.text = widget.address!['zipcode'] ?? '';
      _isDefault = widget.address!['is_default'] ?? false;
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipcode': _zipController.text,
        'is_default': _isDefault,
      };
      if (widget.address != null) {
        await AddressService.updateAddress(widget.address!['id'], data);
      } else {
        await AddressService.addAddress(data);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _streetController,
                decoration: InputDecoration(labelText: 'Street Address'),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
              ),
              TextField(
                controller: _zipController,
                decoration: InputDecoration(labelText: 'ZIP Code'),
              ),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: Text('Set as default'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _save,
                      child: Text('Save Address'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
