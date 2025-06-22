// services/contact_ui_service.dart
import 'package:flutter/material.dart';
import '../screens/contact_logic.dart';

class ContactUIService {
  // Primary theme color
  static const Color primaryColor = Color(0xFF283593);

  /// Get color based on priority
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Group contacts by first letter
  static Map<String, List<Contact>> getGroupedContacts(List<Contact> contacts) {
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in contacts) {
      if (contact.name.isEmpty) continue;
      final firstLetter = contact.name[0].toUpperCase();
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]?.add(contact);
    }
    return groupedContacts;
  }

  /// Get sorted keys for grouped contacts
  static List<String> getSortedKeys(Map<String, List<Contact>> groupedContacts) {
    final sortedKeys = groupedContacts.keys.toList()..sort();
    return sortedKeys;
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      )
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      )
    );
  }
}