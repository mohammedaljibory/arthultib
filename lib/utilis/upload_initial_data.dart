// lib/screens/advanced_upload_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvancedUploadScreen extends StatefulWidget {
  @override
  _AdvancedUploadScreenState createState() => _AdvancedUploadScreenState();
}

class _AdvancedUploadScreenState extends State<AdvancedUploadScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploading = false;
  String _status = '';

  Future<void> uploadCategories() async {
    setState(() {
      _isUploading = true;
      _status = 'Uploading categories...';
    });

    final categories = [
      {
        'nameAr': 'سكرابات',
        'nameEn': 'Scrubs',
        'icon': '👔',
        'order': 1,
        'isActive': true,
        'hasGenderFilter': true,
        'subCategories': [
          {
            'id': 'subcat_medical_scrubs',
            'nameAr': 'سكرابات طبية',
            'nameEn': 'Medical Scrubs',
            'hasGenderFilter': true,
          },
          {
            'id': 'subcat_surgical_scrubs',
            'nameAr': 'سكرابات جراحية',
            'nameEn': 'Surgical Scrubs',
            'hasGenderFilter': true,
          },
          {
            'id': 'subcat_nursing_scrubs',
            'nameAr': 'سكرابات تمريض',
            'nameEn': 'Nursing Scrubs',
            'hasGenderFilter': true,
          },
        ],
      },
      {
        'nameAr': 'أجهزة طبية',
        'nameEn': 'Medical Devices',
        'icon': '🏥',
        'order': 2,
        'isActive': true,
        'hasGenderFilter': false,
        'subCategories': [
          {
            'id': 'subcat_measuring_devices',
            'nameAr': 'أجهزة قياس',
            'nameEn': 'Measuring Devices',
            'hasGenderFilter': false,
          },
          {
            'id': 'subcat_diagnostic_devices',
            'nameAr': 'أجهزة تشخيص',
            'nameEn': 'Diagnostic Devices',
            'hasGenderFilter': false,
          },
          {
            'id': 'subcat_monitoring_devices',
            'nameAr': 'أجهزة مراقبة',
            'nameEn': 'Monitoring Devices',
            'hasGenderFilter': false,
          },
        ],
      },
      {
        'nameAr': 'مستلزمات طبية',
        'nameEn': 'Medical Supplies',
        'icon': '🩹',
        'order': 3,
        'isActive': true,
        'hasGenderFilter': false,
        'subCategories': [
          {
            'id': 'subcat_surgical_supplies',
            'nameAr': 'مستلزمات جراحية',
            'nameEn': 'Surgical Supplies',
            'hasGenderFilter': false,
          },
          {
            'id': 'subcat_protective_equipment',
            'nameAr': 'معدات الحماية',
            'nameEn': 'Protective Equipment',
            'hasGenderFilter': false,
          },
        ],
      },
      {
        'nameAr': 'معدات المستشفيات',
        'nameEn': 'Hospital Equipment',
        'icon': '🏥',
        'order': 4,
        'isActive': true,
        'hasGenderFilter': false,
        'subCategories': [
          {
            'id': 'subcat_patient_beds',
            'nameAr': 'أسرة المرضى',
            'nameEn': 'Patient Beds',
            'hasGenderFilter': false,
          },
          {
            'id': 'subcat_mobility_aids',
            'nameAr': 'مساعدات الحركة',
            'nameEn': 'Mobility Aids',
            'hasGenderFilter': false,
          },
        ],
      },
    ];

    WriteBatch batch = _firestore.batch();

    for (int i = 0; i < categories.length; i++) {
      final categoryId = 'cat_${categories[i]['nameEn'].toString().toLowerCase().replaceAll(' ', '_')}';
      batch.set(
          _firestore.collection('categories').doc(categoryId),
          {
            ...categories[i],
            'createdAt': FieldValue.serverTimestamp(),
          }
      );
    }

    await batch.commit();
    setState(() {
      _status = 'Categories uploaded successfully!';
    });
  }

  Future<void> uploadProducts() async {
    setState(() {
      _status = 'Uploading products...';
    });

    final products = [
      // Scrubs with Gender Variants
      {
        'nameAr': 'سكراب طبي احترافي - أزرق',
        'nameEn': 'Professional Medical Scrub - Blue',
        'sku': 'MED-SCR-001',
        'category': 'سكرابات',
        'categoryId': 'cat_scrubs',
        'subCategory': 'سكرابات طبية',
        'subCategoryId': 'subcat_medical_scrubs',
        'gender': 'men',
        'genderAr': 'رجال',
        'pricing': {
          'public': 123000,
          'wholesale': 100000,
          'vip': 95000,
          'special': 90000,
        },
        'price': 123000,
        'description': 'سكراب طبي عالي الجودة مصنوع من القطن 100%، مصمم خصيصاً للأطباء والممرضين',
        'features': [
          'قماش قطني 100%',
          'مقاوم للبكتيريا',
          'سهل الغسيل والكي',
          'جيوب متعددة عملية',
          'تصميم مريح للحركة'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 150,
        'variants': [
          {
            'id': 'var_001',
            'size': 'S',
            'color': 'أزرق',
            'colorCode': '#0288D1',
            'stock': 20,
          },
          {
            'id': 'var_002',
            'size': 'M',
            'color': 'أزرق',
            'colorCode': '#0288D1',
            'stock': 50,
          },
          {
            'id': 'var_003',
            'size': 'L',
            'color': 'أزرق',
            'colorCode': '#0288D1',
            'stock': 50,
          },
          {
            'id': 'var_004',
            'size': 'XL',
            'color': 'أزرق',
            'colorCode': '#0288D1',
            'stock': 30,
          },
        ],
        'status': 'active',
        'isActive': true,
        'featured': true,
        'tags': ['سكراب', 'طبي', 'رجالي', 'أزرق'],
        'searchKeywords': ['scrub', 'medical', 'men', 'blue', 'سكراب', 'طبي', 'رجال'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'nameAr': 'سكراب طبي نسائي - زهري',
        'nameEn': 'Women\'s Medical Scrub - Pink',
        'sku': 'MED-SCR-002',
        'category': 'سكرابات',
        'categoryId': 'cat_scrubs',
        'subCategory': 'سكرابات طبية',
        'subCategoryId': 'subcat_medical_scrubs',
        'gender': 'women',
        'genderAr': 'نساء',
        'pricing': {
          'public': 123000,
          'wholesale': 100000,
          'vip': 95000,
          'special': 90000,
        },
        'price': 123000,
        'description': 'سكراب طبي نسائي أنيق ومريح، مصمم خصيصاً للطبيبات والممرضات',
        'features': [
          'قماش ناعم ومريح',
          'تصميم أنيق وعصري',
          'مقاوم للبقع',
          'جيوب عملية',
          'قصة مناسبة للنساء'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 120,
        'variants': [
          {
            'id': 'var_001',
            'size': 'S',
            'color': 'زهري',
            'colorCode': '#E91E63',
            'stock': 30,
          },
          {
            'id': 'var_002',
            'size': 'M',
            'color': 'زهري',
            'colorCode': '#E91E63',
            'stock': 40,
          },
          {
            'id': 'var_003',
            'size': 'L',
            'color': 'زهري',
            'colorCode': '#E91E63',
            'stock': 30,
          },
          {
            'id': 'var_004',
            'size': 'XL',
            'color': 'زهري',
            'colorCode': '#E91E63',
            'stock': 20,
          },
        ],
        'status': 'active',
        'isActive': true,
        'featured': true,
        'tags': ['سكراب', 'طبي', 'نسائي', 'زهري'],
        'searchKeywords': ['scrub', 'medical', 'women', 'pink', 'سكراب', 'طبي', 'نساء'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'nameAr': 'سكراب جراحي - أخضر',
        'nameEn': 'Surgical Scrub - Green',
        'sku': 'MED-SCR-003',
        'category': 'سكرابات',
        'categoryId': 'cat_scrubs',
        'subCategory': 'سكرابات جراحية',
        'subCategoryId': 'subcat_surgical_scrubs',
        'gender': 'unisex',
        'genderAr': 'للجنسين',
        'pricing': {
          'public': 150000,
          'wholesale': 125000,
          'vip': 120000,
          'special': 115000,
        },
        'price': 150000,
        'description': 'سكراب جراحي متخصص للعمليات، مصنوع من مواد عالية الجودة',
        'features': [
          'مضاد للميكروبات',
          'قماش خاص للعمليات',
          'مقاوم للسوائل',
          'راحة فائقة',
          'معقم وآمن'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 80,
        'status': 'active',
        'isActive': true,
        'tags': ['سكراب', 'جراحي', 'أخضر'],
        'searchKeywords': ['scrub', 'surgical', 'green', 'سكراب', 'جراحي'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Medical Devices (No Gender)
      {
        'nameAr': 'جهاز قياس ضغط الدم الرقمي',
        'nameEn': 'Digital Blood Pressure Monitor',
        'sku': 'MED-BPM-001',
        'category': 'أجهزة طبية',
        'categoryId': 'cat_medical_devices',
        'subCategory': 'أجهزة قياس',
        'subCategoryId': 'subcat_measuring_devices',
        'gender': 'unisex',
        'genderAr': 'للجميع',
        'pricing': {
          'public': 85000,
          'wholesale': 70000,
          'vip': 65000,
          'special': 60000,
        },
        'price': 85000,
        'description': 'جهاز قياس ضغط رقمي دقيق وسهل الاستخدام مع ذاكرة تخزين',
        'features': [
          'شاشة LCD كبيرة وواضحة',
          'ذاكرة تخزين 90 قراءة',
          'دقة عالية في القياس',
          'بطارية قابلة للشحن USB',
          'مؤشر WHO لضغط الدم'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 45,
        'status': 'active',
        'isActive': true,
        'featured': true,
        'tags': ['جهاز', 'ضغط', 'رقمي'],
        'searchKeywords': ['pressure', 'monitor', 'digital', 'ضغط', 'جهاز'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'nameAr': 'جهاز قياس السكر في الدم',
        'nameEn': 'Blood Glucose Meter',
        'sku': 'MED-BGM-001',
        'category': 'أجهزة طبية',
        'categoryId': 'cat_medical_devices',
        'subCategory': 'أجهزة قياس',
        'subCategoryId': 'subcat_measuring_devices',
        'gender': 'unisex',
        'genderAr': 'للجميع',
        'pricing': {
          'public': 65000,
          'wholesale': 55000,
          'vip': 50000,
          'special': 45000,
        },
        'price': 65000,
        'description': 'جهاز قياس سكر الدم سريع ودقيق مع شرائط اختبار',
        'features': [
          'نتائج في 5 ثواني',
          'ذاكرة 500 قراءة',
          'شاشة كبيرة مضيئة',
          'تنبيهات صوتية',
          'يشمل 50 شريط اختبار'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 60,
        'status': 'active',
        'isActive': true,
        'tags': ['جهاز', 'سكر', 'دم'],
        'searchKeywords': ['glucose', 'meter', 'blood', 'سكر', 'جهاز'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Medical Supplies
      {
        'nameAr': 'قفازات طبية نيتريل - علبة 100',
        'nameEn': 'Nitrile Medical Gloves - Box of 100',
        'sku': 'MED-GLV-001',
        'category': 'مستلزمات طبية',
        'categoryId': 'cat_medical_supplies',
        'subCategory': 'معدات الحماية',
        'subCategoryId': 'subcat_protective_equipment',
        'gender': 'unisex',
        'genderAr': 'للجميع',
        'pricing': {
          'public': 25000,
          'wholesale': 20000,
          'vip': 18000,
          'special': 16000,
        },
        'price': 25000,
        'description': 'قفازات طبية عالية الجودة خالية من البودرة',
        'features': [
          'خالية من اللاتكس',
          'مقاومة للثقب',
          'ملمس محكم للإمساك',
          'معقمة 100%',
          'مقاسات متعددة'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 500,
        'variants': [
          {
            'id': 'var_001',
            'size': 'S',
            'stock': 100,
          },
          {
            'id': 'var_002',
            'size': 'M',
            'stock': 200,
          },
          {
            'id': 'var_003',
            'size': 'L',
            'stock': 150,
          },
          {
            'id': 'var_004',
            'size': 'XL',
            'stock': 50,
          },
        ],
        'status': 'active',
        'isActive': true,
        'tags': ['قفازات', 'طبية', 'نيتريل'],
        'searchKeywords': ['gloves', 'medical', 'nitrile', 'قفازات'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Hospital Equipment
      {
        'nameAr': 'كرسي متحرك طبي',
        'nameEn': 'Medical Wheelchair',
        'sku': 'MED-WCH-001',
        'category': 'معدات المستشفيات',
        'categoryId': 'cat_hospital_equipment',
        'subCategory': 'مساعدات الحركة',
        'subCategoryId': 'subcat_mobility_aids',
        'gender': 'unisex',
        'genderAr': 'للجميع',
        'pricing': {
          'public': 850000,
          'wholesale': 750000,
          'vip': 700000,
          'special': 650000,
        },
        'price': 850000,
        'description': 'كرسي متحرك طبي قابل للطي مع مساند قدم قابلة للتعديل',
        'features': [
          'إطار من الألومنيوم الخفيف',
          'قابل للطي بسهولة',
          'مساند أذرع قابلة للإزالة',
          'فرامل آمنة',
          'وزن خفيف 12 كجم'
        ],
        'images': ['https://via.placeholder.com/600'],
        'thumbnail': 'https://via.placeholder.com/300',
        'stock': 15,
        'status': 'active',
        'isActive': true,
        'tags': ['كرسي', 'متحرك', 'طبي'],
        'searchKeywords': ['wheelchair', 'medical', 'كرسي', 'متحرك'],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    WriteBatch batch = _firestore.batch();

    for (var product in products) {
      final docRef = _firestore.collection('products').doc();
      batch.set(docRef, product);
    }

    await batch.commit();
    setState(() {
      _status = 'Products uploaded successfully!';
      _isUploading = false;
    });
  }

  Future<void> uploadSampleUsers() async {
    setState(() {
      _status = 'Creating sample users...';
    });

    final users = [
      {
        'email': 'wholesale@example.com',
        'name': 'تاجر الجملة',
        'userType': 'wholesale',
        'discount': 0.0,
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'vip@example.com',
        'name': 'عميل VIP',
        'userType': 'vip',
        'discount': 0.05, // 5% additional discount
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'special@example.com',
        'name': 'عميل خاص',
        'userType': 'special',
        'discount': 0.1, // 10% additional discount
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    WriteBatch batch = _firestore.batch();

    for (var user in users) {
      // In real app, you'd create actual Firebase Auth users
      // This is just for demonstration
      final docRef = _firestore.collection('users').doc();
      batch.set(docRef, user);
    }

    await batch.commit();
    setState(() {
      _status = 'Sample users created!';
    });
  }

  Future<void> uploadAllData() async {
    await uploadCategories();
    await uploadProducts();
    await uploadSampleUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Advanced Data'),
        backgroundColor: Color(0xFF0288D1),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isUploading)
                CircularProgressIndicator(),

              SizedBox(height: 20),

              Text(
                _status,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isUploading ? null : uploadAllData,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Upload All Data',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0288D1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'This will upload:\n'
                    '• 4 Categories with subcategories\n'
                    '• 7 Products with pricing tiers\n'
                    '• 3 Sample user types',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}