// services/contact_service.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ContactService {
  /// Makes a phone call to the given phone number
  /// This will open the phone's dialer with the number pre-filled
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      // Clean the phone number (remove spaces, special characters except +)
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      
      if (cleanNumber.isEmpty) {
        if (kDebugMode) {
          print('Invalid phone number: $phoneNumber');
        }
        return false;
      }
      
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      
      if (kDebugMode) {
        print('Attempting to launch: $phoneUri');
      }
      
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (kDebugMode) {
          print('Cannot launch phone dialer for: $phoneUri');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error making call: $e');
      }
      return false;
    }
  }
  
  /// Opens WhatsApp chat with the given phone number
  /// If WhatsApp is not installed, it will open in browser
  static Future<bool> sendWhatsAppMessage(String phoneNumber, {String? message}) async {
    try {
      // Clean the phone number and ensure it starts with country code
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      
      if (cleanNumber.isEmpty) {
        if (kDebugMode) {
          print('Invalid phone number for WhatsApp: $phoneNumber');
        }
        return false;
      }
      
      // Ensure the number starts with country code (remove leading + if present)
      String formattedNumber = cleanNumber;
      if (formattedNumber.startsWith('+')) {
        formattedNumber = formattedNumber.substring(1);
      }
      
      // Create WhatsApp URL
      String whatsappUrl;
      if (message != null && message.isNotEmpty) {
        final encodedMessage = Uri.encodeComponent(message);
        whatsappUrl = 'https://wa.me/$formattedNumber?text=$encodedMessage';
      } else {
        whatsappUrl = 'https://wa.me/$formattedNumber';
      }
      
      final Uri whatsappUri = Uri.parse(whatsappUrl);
      
      if (kDebugMode) {
        print('Attempting to launch WhatsApp: $whatsappUri');
      }
      
      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(
          whatsappUri, 
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: try to open WhatsApp app directly
        final Uri fallbackUri = Uri.parse('whatsapp://send?phone=$formattedNumber${message != null ? '&text=${Uri.encodeComponent(message)}' : ''}');
        
        if (await canLaunchUrl(fallbackUri)) {
          return await launchUrl(
            fallbackUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (kDebugMode) {
            print('Cannot launch WhatsApp for: $whatsappUri');
          }
          return false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending WhatsApp message: $e');
      }
      return false;
    }
  }
  
  /// Send SMS to the given phone number
  static Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      
      if (cleanNumber.isEmpty) {
        if (kDebugMode) {
          print('Invalid phone number for SMS: $phoneNumber');
        }
        return false;
      }
      
      String smsUrl = 'sms:$cleanNumber';
      if (message != null && message.isNotEmpty) {
        smsUrl += '?body=${Uri.encodeComponent(message)}';
      }
      
      final Uri smsUri = Uri.parse(smsUrl);
      
      if (kDebugMode) {
        print('Attempting to launch SMS: $smsUri');
      }
      
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (kDebugMode) {
          print('Cannot launch SMS for: $smsUri');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending SMS: $e');
      }
      return false;
    }
  }
  
  /// Send email to the given email address
  static Future<bool> sendEmail(String email, {String? subject, String? body}) async {
    try {
      if (email.isEmpty || !_isValidEmail(email)) {
        if (kDebugMode) {
          print('Invalid email address: $email');
        }
        return false;
      }
      
      String emailUrl = 'mailto:$email';
      List<String> params = [];
      
      if (subject != null && subject.isNotEmpty) {
        params.add('subject=${Uri.encodeComponent(subject)}');
      }
      
      if (body != null && body.isNotEmpty) {
        params.add('body=${Uri.encodeComponent(body)}');
      }
      
      if (params.isNotEmpty) {
        emailUrl += '?${params.join('&')}';
      }
      
      final Uri emailUri = Uri.parse(emailUrl);
      
      if (kDebugMode) {
        print('Attempting to launch email: $emailUri');
      }
      
      if (await canLaunchUrl(emailUri)) {
        return await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (kDebugMode) {
          print('Cannot launch email for: $emailUri');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email: $e');
      }
      return false;
    }
  }
  
  /// Shares contact details as text
  static Future<bool> shareContact({
    required String name,
    required String phoneNumber,
    String? email,
    String? address,
    String? note,
  }) async {
    try {
      // Build contact details string
      StringBuffer contactDetails = StringBuffer();
      contactDetails.writeln('📱 Contact Details');
      contactDetails.writeln('━━━━━━━━━━━━━━━━━━━━');
      contactDetails.writeln('👤 Name: $name');
      contactDetails.writeln('📞 Phone: $phoneNumber');
      
      if (email != null && email.isNotEmpty) {
        contactDetails.writeln('📧 Email: $email');
      }
      
      if (address != null && address.isNotEmpty) {
        contactDetails.writeln('📍 Address: $address');
      }
      
      if (note != null && note.isNotEmpty) {
        contactDetails.writeln('📝 Note: $note');
      }
      
      contactDetails.writeln('━━━━━━━━━━━━━━━━━━━━');
      contactDetails.writeln('Shared via Contact App');
      
      // Share the contact details
      await Share.share(
        contactDetails.toString(),
        subject: 'Contact: $name',
      );
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing contact: $e');
      }
      return false;
    }
  }
  
  /// Shares contact as VCard format
  static Future<bool> shareContactAsVCard({
    required String name,
    required String phoneNumber,
    String? email,
    String? address,
    String? note,
  }) async {
    try {
      // Create VCard format
      StringBuffer vcard = StringBuffer();
      vcard.writeln('BEGIN:VCARD');
      vcard.writeln('VERSION:3.0');
      vcard.writeln('FN:$name');
      
      // Split name into first and last name
      final nameParts = name.split(' ');
      if (nameParts.length >= 2) {
        vcard.writeln('N:${nameParts.last};${nameParts.first};;;');
      } else {
        vcard.writeln('N:;$name;;;');
      }
      
      vcard.writeln('TEL:$phoneNumber');
      
      if (email != null && email.isNotEmpty) {
        vcard.writeln('EMAIL:$email');
      }
      
      if (address != null && address.isNotEmpty) {
        vcard.writeln('ADR:;;$address;;;;');
      }
      
      if (note != null && note.isNotEmpty) {
        vcard.writeln('NOTE:$note');
      }
      
      vcard.writeln('END:VCARD');
      
      // Share the VCard
      await Share.share(
        vcard.toString(),
        subject: 'Contact: $name',
      );
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing VCard: $e');
      }
      return false;
    }
  }
  
  /// Copy contact details to clipboard
  static Future<bool> copyToClipboard({
    required String name,
    required String phoneNumber,
    String? email,
  }) async {
    try {
      StringBuffer contactText = StringBuffer();
      contactText.write('$name - $phoneNumber');
      
      if (email != null && email.isNotEmpty) {
        contactText.write(' - $email');
      }
      
      await Clipboard.setData(ClipboardData(text: contactText.toString()));
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error copying to clipboard: $e');
      }
      return false;
    }
  }
  
  /// Clean phone number by removing unwanted characters
  static String _cleanPhoneNumber(String phoneNumber) {
    // Remove all characters except digits, +, and spaces
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d\+\s]'), '');
    
    // Remove extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    
    return cleaned;
  }
  
  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    
    // Basic validation: should have at least 10 digits
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10;
  }
  
  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber, {String countryCode = '+91'}) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    
    if (cleaned.startsWith('+')) {
      return cleaned;
    } else if (cleaned.startsWith(countryCode.substring(1))) {
      return '+$cleaned';
    } else {
      return '$countryCode$cleaned';
    }
  }
  
  /// Check if a specific app is available
  static Future<bool> isAppAvailable(String scheme) async {
    try {
      final uri = Uri.parse(scheme);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
  
  /// Check if WhatsApp is available
  static Future<bool> isWhatsAppAvailable() async {
    return await isAppAvailable('whatsapp://') || 
           await isAppAvailable('https://wa.me/1234567890');
  }
}