// logic/contacts_page_logic.dart
import 'package:flutter/material.dart';
import '../screens/contact_logic.dart';
import '../services/contact_repository_services.dart';
import '../services/contact_ui_services.dart';

class ContactsPageLogic {
  // List to store contacts
  List<Contact> contacts = [];
  
  // Loading state
  bool isLoading = true;
  
  // Current selected tab
  ContactType selectedTab = ContactType.primary;

  /// Function to update loading state with a callback to update UI
  void setLoading(bool loading, Function(bool) updateState) {
    isLoading = loading;
    updateState(loading);
  }
  
  /// Set selected tab with a callback to update UI
  void setSelectedTab(ContactType type, Function(ContactType) updateState) {
    selectedTab = type;
    updateState(type);
  }
  
  /// Set contact list with a callback to update UI
  void setContacts(List<Contact> newContacts, Function(List<Contact>) updateState) {
    contacts = newContacts;
    updateState(newContacts);
  }
  
  /// Load contacts based on selected tab
  Future<void> loadContacts(
    BuildContext context, 
    Function(bool) updateLoadingState, 
    Function(List<Contact>) updateContactsState
  ) async {
    setLoading(true, updateLoadingState);
    
    try {
      final loadedContacts = await ContactRepositoryService.loadContacts(selectedTab);
      setContacts(loadedContacts, updateContactsState);
      setLoading(false, updateLoadingState);
    } catch (e) {
      setLoading(false, updateLoadingState);
      
      // Show appropriate error message
      if (e.toString().contains('using cached data')) {
        ContactUIService.showInfoSnackBar(context, 'Using cached contacts - ${e.toString()}');
      } else {
        ContactUIService.showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }
  
  /// Force a full refresh (for pull-to-refresh functionality)
  Future<void> refreshContacts(
    BuildContext context, 
    Function(bool) updateLoadingState, 
    Function(List<Contact>) updateContactsState
  ) async {
    setLoading(true, updateLoadingState);
    
    try {
      final refreshedContacts = await ContactRepositoryService.refreshContacts(selectedTab);
      setContacts(refreshedContacts, updateContactsState);
      setLoading(false, updateLoadingState);
      ContactUIService.showSuccessSnackBar(context, 'Contacts refreshed successfully');
    } catch (e) {
      setLoading(false, updateLoadingState);
      ContactUIService.showErrorSnackBar(context, 'Failed to refresh: ${e.toString()}');
    }
  }
  
  /// Get color based on priority (delegates to UI service)
  Color getPriorityColor(int priority) {
    return ContactUIService.getPriorityColor(priority);
  }
  
  /// Group contacts by first letter (delegates to UI service)
  Map<String, List<Contact>> getGroupedContacts() {
    return ContactUIService.getGroupedContacts(contacts);
  }
  
  /// Get sorted keys for grouped contacts (delegates to UI service)
  List<String> getSortedKeys(Map<String, List<Contact>> groupedContacts) {
    return ContactUIService.getSortedKeys(groupedContacts);
  }

  /// Get primary theme color
  Color get primaryColor => ContactUIService.primaryColor;
}