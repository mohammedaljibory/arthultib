
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final _addressController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(33.3152, 44.3661); // Najaf coordinates
  String _selectedAddress = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Move camera to current position
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 16),
      );

      // Get address from coordinates
      await _getAddressFromLatLng(_currentPosition);
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = '${place.street}, ${place.locality}, ${place.country}';
          _addressController.text = _selectedAddress;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('صلاحية الموقع'),
        content: const Text('الرجاء تفعيل صلاحية الموقع في الإعدادات لاستخدام هذه الميزة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _confirmAddress() {
    if (_addressController.text.isNotEmpty) {
      Navigator.pop(context, {
        'address': _addressController.text,
        'latitude': _currentPosition.latitude,
        'longitude': _currentPosition.longitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال أو اختيار عنوان'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'اختر العنوان',
            style: TextStyle(color: Colors.black87),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (LatLng position) {
                setState(() {
                  _currentPosition = position;
                });
                _getAddressFromLatLng(position);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _currentPosition,
                  infoWindow: const InfoWindow(title: 'الموقع المختار'),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),

            // Address input and controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عنوان التوصيل',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address input
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'أدخل العنوان يدوياً',
                        hintText: 'الشارع، المدينة، البلد',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 2,
                      minLines: 1,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        // Current location button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _getCurrentLocation,
                            icon: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Icon(Icons.my_location),
                            label: const Text('موقعي الحالي'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Confirm button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmAddress,
                            child: const Text('تأكيد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004080),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}