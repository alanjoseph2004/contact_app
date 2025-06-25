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
      // Get properly formatted dialable number
      final dialableNumber = getDialableNumber(phoneNumber);
      
      if (dialableNumber.isEmpty || !isValidPhoneNumber(phoneNumber)) {
        if (kDebugMode) {
          print('Invalid phone number: $phoneNumber -> $dialableNumber');
        }
        return false;
      }
      
      final Uri phoneUri = Uri(scheme: 'tel', path: dialableNumber);
      
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
      // Get properly formatted dialable number
      final dialableNumber = getDialableNumber(phoneNumber);
      
      if (dialableNumber.isEmpty || !isValidPhoneNumber(phoneNumber)) {
        if (kDebugMode) {
          print('Invalid phone number for WhatsApp: $phoneNumber -> $dialableNumber');
        }
        return false;
      }
      
      // Remove + for WhatsApp URL (WhatsApp expects numbers without +)
      String whatsappNumber = dialableNumber;
      if (whatsappNumber.startsWith('+')) {
        whatsappNumber = whatsappNumber.substring(1);
      }
      
      // Create WhatsApp URL
      String whatsappUrl;
      if (message != null && message.isNotEmpty) {
        final encodedMessage = Uri.encodeComponent(message);
        whatsappUrl = 'https://wa.me/$whatsappNumber?text=$encodedMessage';
      } else {
        whatsappUrl = 'https://wa.me/$whatsappNumber';
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
        final Uri fallbackUri = Uri.parse('whatsapp://send?phone=$whatsappNumber${message != null ? '&text=${Uri.encodeComponent(message)}' : ''}');
        
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
    // Remove all characters except digits and +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d\+]'), '');
    
    // Handle Indian numbers specifically
    if (cleaned.length == 10 && !cleaned.startsWith('+')) {
      // Add Indian country code for 10-digit numbers
      cleaned = '+91$cleaned';
    } else if (cleaned.length == 11 && cleaned.startsWith('91') && !cleaned.startsWith('+')) {
      // Add + for 11-digit numbers starting with 91
      cleaned = '+$cleaned';
    } else if (cleaned.length == 12 && cleaned.startsWith('91') && !cleaned.startsWith('+')) {
      // This might be a number with extra digit, remove leading 0 if present
      if (cleaned.startsWith('910')) {
        cleaned = '+91${cleaned.substring(3)}';
      } else {
        cleaned = '+$cleaned';
      }
    } else if (cleaned.length == 13 && cleaned.startsWith('+91')) {
      // This might have extra digit, check for leading 0 after country code
      if (cleaned.startsWith('+910')) {
        cleaned = '+91${cleaned.substring(4)}';
      }
    }
    
    return cleaned;
  }
  
  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    
    // Check if it's a valid Indian number format
    if (cleaned.startsWith('+91')) {
      final digits = cleaned.substring(3); // Remove +91
      return digits.length == 10 && 
             digits.startsWith(RegExp(r'[6-9]')); // Indian mobile numbers start with 6,7,8,9
    }
    
    // For other international numbers, basic validation
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }
  
  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber, {String countryCode = '+91'}) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    
    // If already properly formatted, return as is
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return cleaned;
    }
    
    // Handle different input formats
    if (cleaned.length == 10 && cleaned.startsWith(RegExp(r'[6-9]'))) {
      return '+91$cleaned';
    } else if (cleaned.startsWith('+')) {
      return cleaned;
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    } else {
      return cleaned; // Return as is for international numbers
    }
  }
  
  /// Get formatted phone number specifically for dialing
  static String getDialableNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    
    if (kDebugMode) {
      print('Original number: $phoneNumber');
      print('Cleaned number: $cleaned');
    }
    
    // For Indian numbers, ensure proper format
    if (cleaned.startsWith('+91')) {
      return cleaned;
    } else if (cleaned.length == 10 && cleaned.startsWith(RegExp(r'[6-9]'))) {
      return '+91$cleaned';
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }
    
    // For other formats, return cleaned version
    return cleaned;
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