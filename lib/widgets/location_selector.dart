import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LocationSelector extends StatefulWidget {
  final Function(String address, double? lat, double? lng) onLocationSelected;
  final String? currentAddress;

  const LocationSelector({
    Key? key,
    required this.onLocationSelected,
    this.currentAddress,
  }) : super(key: key);

  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final TextEditingController _manualAddressController = TextEditingController();
  bool _isLoadingLocation = false;
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    if (widget.currentAddress != null) {
      _manualAddressController.text = widget.currentAddress!;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('تم رفض صلاحية الموقع');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';

        widget.onLocationSelected(address, position.latitude, position.longitude);

        if (mounted) {
          _showSuccessDialog('تم تحديد موقعك بنجاح');
        }
      }
    } catch (e) {
      _showErrorDialog('فشل في تحديد الموقع: ${e.toString()}');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 10),
            Text('اختر طريقة تحديد الموقع'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.my_location, color: Colors.blue),
              title: Text('موقعي الحالي'),
              subtitle: Text('استخدام GPS لتحديد موقعك'),
              onTap: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit_location, color: Colors.orange),
              title: Text('إدخال العنوان يدوياً'),
              subtitle: Text('اكتب عنوانك بنفسك'),
              onTap: () {
                Navigator.pop(context);
                _showManualAddressDialog();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.map, color: Colors.green),
              title: Text('اختر من الخريطة'),
              subtitle: Text('حدد موقعك على الخريطة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/map-selection');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('أدخل عنوانك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _manualAddressController,
              decoration: InputDecoration(
                labelText: 'العنوان الكامل',
                hintText: 'المحافظة، المنطقة، الشارع، رقم البناية',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 3,
              minLines: 2,
            ),
            SizedBox(height: 10),
            Text(
              'مثال: النجف، حي السلام، شارع المدينة، بناية رقم 10',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_manualAddressController.text.isNotEmpty) {
                widget.onLocationSelected(_manualAddressController.text, null, null);
                Navigator.pop(context);
                _showSuccessDialog('تم حفظ العنوان بنجاح');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('الرجاء إدخال العنوان'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text('حفظ'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('صلاحية الموقع مطلوبة'),
        content: Text('يرجى تفعيل صلاحية الموقع من إعدادات التطبيق لاستخدام هذه الميزة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('فتح الإعدادات'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 15),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('خطأ'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hasAddress = authProvider.currentUser?.address != null &&
        authProvider.currentUser!.address!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عنوان التوصيل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoadingLocation)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          SizedBox(height: 12),

          if (hasAddress) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.currentUser!.address!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 18),
                    onPressed: _showLocationMethodDialog,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ] else ...[
            InkWell(
              onTap: _showLocationMethodDialog,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_location, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'اضغط لإضافة عنوان التوصيل',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _manualAddressController.dispose();
    super.dispose();
  }
}