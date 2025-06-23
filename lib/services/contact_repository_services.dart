import '../screens/contact_logic.dart';
import 'contact_api_service.dart';
import 'contact_cache_service.dart';

class ContactRepositoryService {
  /// Load contacts based on type - always fetch fresh data from API
  static Future<List<Contact>> loadContacts(ContactType type) async {
    if (type == ContactType.primary) {
      return await _fetchAndCachePrimaryContacts();
    } else if (type == ContactType.all) {
      return await _fetchAndCacheAllContacts();
    } else if (type == ContactType.both) {
      // Load both primary and all contacts
      final primaryContacts = await ContactService.getPrimaryContactsFromStorage();
      final allContacts = await ContactService.getAllContactsFromStorage();
      
      // Merge and return both types
      final Map<int, Contact> contactMap = {};
      
      // Add primary contacts first
      for (var contact in primaryContacts) {
        contactMap[contact.id] = contact;
      }
      
      // Add all contacts (non-duplicates)
      for (var contact in allContacts) {
        if (!contactMap.containsKey(contact.id)) {
          contactMap[contact.id] = contact;
        }
      }
      
      return contactMap.values.toList();
    } else {
      // Fallback to general contacts storage
      return await ContactService.getContacts();
    }
  }

  /// Force refresh contacts (for pull-to-refresh) - same as loadContacts now
  static Future<List<Contact>> refreshContacts(ContactType type) async {
    return await loadContacts(type); // Simply delegate to loadContacts
  }

  /// Fetch and cache primary contacts from API
  static Future<List<Contact>> _fetchAndCachePrimaryContacts() async {
    try {
      // Fetch contacts from API (this returns List<Contact>)
      final contacts = await ContactApiService.fetchPrimaryContacts();
      
      // Convert to the raw API response format that cacheApiPrimaryContacts expects
      // Since cacheApiPrimaryContacts expects List<Map<String, dynamic>>, we need to 
      // bypass it and directly save the contacts
      await ContactService.savePrimaryContacts(contacts);
      
      // Save timestamp for future reference
      await ContactCacheService.saveLastFetchTimestamp(ContactType.primary);
      await ContactCacheService.setHasInitialData(true);
      
      return contacts;
    } catch (e) {
      print('Error fetching primary contacts: $e');
      // Try to load from cache if API fails
      final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
      if (cachedContacts.isNotEmpty) {
        // Return cached data but still throw to show user that we're using cached data
        throw Exception('Failed to load fresh primary contacts, using cached data: $e');
      }
      // No cached data available
      throw Exception('Failed to load primary contacts and no cache available: $e');
    }
  }

  /// Fetch and cache all contacts from API
  static Future<List<Contact>> _fetchAndCacheAllContacts() async {
    try {
      final contacts = await ContactApiService.fetchAllContacts();
      
      // Cache all contacts using the method from ContactService
      await ContactService.cacheApiAllContacts(contacts);
      
      // Save timestamp for future reference
      await ContactCacheService.saveLastFetchTimestamp(ContactType.all);
      await ContactCacheService.setHasInitialData(true);
      
      // Return all contacts (don't filter out primary contacts here)
      return contacts;
    } catch (e) {
      print('Error fetching all contacts: $e');
      // Try to load from cache if API fails
      final cachedContacts = await ContactService.getAllContactsFromStorage();
      if (cachedContacts.isNotEmpty) {
        // Return cached data and throw to show user that we're using cached data
        throw Exception('Failed to load fresh all contacts, using cached data: $e');
      }
      // No cached data available
      throw Exception('Failed to load all contacts and no cache available: $e');
    }
  }

  /// Get contacts by specific criteria
  static Future<List<Contact>> getContactsByType(ContactType type) async {
    return await ContactService.getContactsByType(type);
  }

  /// Get priority contacts
  static Future<List<Contact>> getPriorityContacts() async {
    return await ContactService.getPriorityContacts();
  }

  /// Search contacts
  static Future<List<Contact>> searchContacts(String query) async {
    return await ContactService.searchContacts(query);
  }

  /// Get contacts by tag
  static Future<List<Contact>> getContactsByTag(int tagId) async {
    return await ContactService.getContactsByTag(tagId);
  }

  /// Get contacts by district
  static Future<List<Contact>> getContactsByDistrict(int districtId) async {
    return await ContactService.getContactsByDistrict(districtId);
  }

  /// Get contacts by assembly constituency
  static Future<List<Contact>> getContactsByAssemblyConstituency(int constituencyId) async {
    return await ContactService.getContactsByAssemblyConstituency(constituencyId);
  }

  /// Get contacts by booth
  static Future<List<Contact>> getContactsByBooth(int boothId) async {
    return await ContactService.getContactsByBooth(boothId);
  }

  /// Get contacts by referral
  static Future<List<Contact>> getContactsByReferral(int referredBy) async {
    return await ContactService.getContactsByReferral(referredBy);
  }

  /// Get contact by primary contact ID
  static Future<Contact?> getContactByPrimaryContactId(int primaryContactId) async {
    return await ContactService.getContactByPrimaryContactId(primaryContactId);
  }

  /// Add a new contact
  static Future<bool> addContact(Contact contact) async {
    try {
      // First add to local storage
      final success = await ContactService.addContact(contact);
      
      if (success) {
        // TODO: Add API call to sync with server
        // await ContactApiService.createContact(contact);
      }
      
      return success;
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  /// Update an existing contact
  static Future<bool> updateContact(Contact contact) async {
    try {
      // First update in local storage
      final success = await ContactService.updateContact(contact);
      
      if (success) {
        // TODO: Add API call to sync with server
        // await ContactApiService.updateContact(contact);
      }
      
      return success;
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  /// Get contact statistics
  static Future<Map<String, int>> getContactStatistics() async {
    return await ContactService.getContactStatistics();
  }

  /// Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    return await ContactService.getLastSyncTime();
  }

  /// Utility method to merge contacts (kept for future use when implementing timed retrieval)
  static List<Contact> _mergeContacts(List<Contact> cachedContacts, List<Contact> updatedContacts) {
    // Create a map from cached contacts for easy lookup
    Map<int, Contact> contactMap = {
      for (var contact in cachedContacts) contact.id: contact
    };
    
    // Update or add new contacts
    for (var contact in updatedContacts) {
      contactMap[contact.id] = contact;
    }
    
    // Convert back to list
    return contactMap.values.toList();
  }

  /// Clear all cached data (utility method for debugging or reset)
  static Future<void> clearAllCache() async {
    await ContactCacheService.clearTimestamps();
    await ContactService.clearAllContacts();
  }

  /// Check if we have initial data
  static Future<bool> hasInitialData() async {
    return await ContactCacheService.hasInitialData();
  }

  /// Force a complete refresh of all contact types
  static Future<void> forceRefreshAll() async {
    try {
      await Future.wait([
        _fetchAndCachePrimaryContacts(),
        _fetchAndCacheAllContacts(),
      ]);
    } catch (e) {
      throw Exception('Failed to refresh all contacts: $e');
    }
  }
}