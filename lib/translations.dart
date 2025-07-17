import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class Translations {
  static const Map<String, Map<String, String>> translations = {
    'ar': {
      'appTitle': 'أرض الطب',
      'homeSectionTitle': 'وجهتك الأولى للمستلزمات الطبية عالية الجودة',
      'homeSectionDescription': 'نحن في شركة أرض الطب نوفر لك كل ما تحتاجه من مستلزمات طبية بأعلى معايير الجودة العالمية.',
      'homeSectionDetails': 'سواء كنت تبحث عن أجهزة طبية، مستلزمات المستشفيات، أو الأدوات الطبية الشخصية، نحن هنا لنلبي احتياجاتك بأفضل الأسعار وأعلى مستوى من الخدمة.',
      'aboutSectionTitle': 'شريكك الموثوق في عالم المستلزمات الطبية!',
      'aboutSectionDescription': 'تأسست شركة أرض الطب بهدف توفير حلول طبية متكاملة للأفراد والمستشفيات والعيادات الطبية.\nنسعى دائمًا لنكون من الشركات الموردة للمستلزمات الطبية من خلال تقديم أحدث التقنيات وأفضل المنتجات الطبية.',
      'aboutVisionTitle': 'رؤيتنا',
      'aboutVisionDescription': 'أن نكون المورد الأول للمستلزمات الطبية في المنطقة، بتقديم منتجات موثوقة تلبي احتياجات السوق الطبي المتنامي.',
      'aboutMissionTitle': 'رسالتنا',
      'aboutMissionDescription': 'تقديم منتجات طبية معتمدة تساعد في تحسين جودة الرعاية الصحية، مع التركيز على خدمة العملاء والابتكار المستمر.',
      'contactSectionTitle': 'اتصل بنا',
      'contactSectionSubtitle': 'هل تبحث عن معلومات إضافية؟',
      'companyAddress': 'عنوان الشركة',
      'callUs': 'اتصل بي',
      'emailUs': 'ارسل لي',
      'productsSectionTitle': 'المنتجات',
      'productsSectionDescription': 'نقدم مجموعة واسعة من المنتجات عالية الجودة لتلبية احتياجاتكم.',
      'storeVisitButton': 'زور متجرنا', // التأكد من وجود هذا المفتاح
      'gallerySectionTitle': 'معرض الصور',
      'galleryNoImages': 'لا توجد صور متاحة في المعرض',
      'galleryImageLoadError': 'فشل تحميل الصورة',
      'originsSectionTitle': 'المناشئ',
      'originsNoData': 'لا توجد بيانات متاحة',
      'originsImageLoadError': 'فشل تحميل الصورة',
      'originsImageNotAvailable': 'الصورة غير متاحة',
      'brandInfoComingSoon': 'معلومات إضافية عن {brandName} قريبًا!',
      'close': 'إغلاق',
      'storeAllCategory': 'الكل',
      'storeMedicalDevices': 'أجهزة طبية',
      'storeElectronics': 'إلكترونيات',
      'storeOthers': 'آخرى',
      'storeAddToCart': 'إضافة إلى العربة',
      'storeAddedToCart': 'تمت الإضافة إلى العربة',
      'notAvailable': 'غير متوفر',
      'storeComingSoon': 'قريبًا سوف يتوفر المتجر',
      'changeLanguage': 'تغيير اللغة',
    },
    'en': {
      'appTitle': 'Arthultib',
      'homeSectionTitle': 'Your Premier Destination for High-Quality Medical Supplies',
      'homeSectionDescription': 'At Arthultib, we provide everything you need in medical supplies with the highest global quality standards.',
      'homeSectionDetails': 'Whether you are looking for medical devices, hospital supplies, or personal medical tools, we are here to meet your needs with the best prices and the highest level of service.',
      'aboutSectionTitle': 'Your Trusted Partner in the World of Medical Supplies!',
      'aboutSectionDescription': 'Arthultib was established with the goal of providing comprehensive medical solutions for individuals, hospitals, and medical clinics.\nWe always strive to be among the leading suppliers of medical supplies by offering the latest technologies and the best medical products.',
      'aboutVisionTitle': 'Our Vision',
      'aboutVisionDescription': 'To be the leading supplier of medical supplies in the region, delivering reliable products that meet the growing needs of the medical market.',
      'aboutMissionTitle': 'Our Mission',
      'aboutMissionDescription': 'To provide certified medical products that enhance the quality of healthcare, with a focus on customer service and continuous innovation.',
      'contactSectionTitle': 'Contact Us',
      'contactSectionSubtitle': 'Looking for more information?',
      'companyAddress': 'Company Address',
      'callUs': 'Call Us',
      'emailUs': 'Email Us',
      'productsSectionTitle': 'Products',
      'productsSectionDescription': 'We offer a wide range of high-quality products to meet your needs.',
      'storeVisitButton': 'Visit Our Store', // التأكد من وجود هذا المفتاح
      'gallerySectionTitle': 'Gallery',
      'galleryNoImages': 'No images available in the gallery',
      'galleryImageLoadError': 'Failed to load image',
      'originsSectionTitle': 'Origins',
      'originsNoData': 'No data available',
      'originsImageLoadError': 'Failed to load image',
      'originsImageNotAvailable': 'Image not available',
      'brandInfoComingSoon': 'Additional information about {brandName} coming soon!',
      'close': 'Close',
      'storeAllCategory': 'All',
      'storeMedicalDevices': 'Medical Devices',
      'storeElectronics': 'Electronics',
      'storeOthers': 'Others',
      'storeAddToCart': 'Add to Cart',
      'storeAddedToCart': 'Added to Cart',
      'notAvailable': 'Not available',
      'storeComingSoon': 'The store will be available soon',
      'changeLanguage': 'Change Language',
    },
  };

  static String getText(BuildContext context, String key, {Map<String, String>? params}) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).languageCode;
    String text = translations[languageCode]?[key] ?? translations['ar']![key] ?? 'Key not found: $key';
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }
}