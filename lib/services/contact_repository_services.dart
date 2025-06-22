import '../screens/contact_logic.dart';
import 'contact_api_service.dart';
import 'contact_cache_service.dart';

class ContactRepositoryService {
  /// Load contacts based on type, handling initial fetch vs updates
  static Future<List<Contact>> loadContacts(ContactType type) async {
    bool hasInitialData = await ContactCacheService.hasInitialData();
    
    if (type == ContactType.primary) {
      if (!hasInitialData) {
        return await _fetchAndCachePrimaryContacts();
      } else {
        // For primary contacts, we can use a timed retrieval approach
        // return await _fetchUpdatedPrimaryContacts();
        // For now, let's just fetch and cache again
        return await _fetchAndCachePrimaryContacts();
      }
    } else if (type == ContactType.all) {
      if (!hasInitialData) {
        return await _fetchAndCacheAllContacts();
      } else {
        // For all contacts, we can use a timed retrieval approach
        // return await _fetchUpdatedAllContacts();
        // For now, let's just fetch and cache again
        return await _fetchAndCacheAllContacts();
      }
    } else {
      // Local contacts
      return await ContactService.getContacts();
    }
  }

  /// Force refresh contacts (for pull-to-refresh)
  static Future<List<Contact>> refreshContacts(ContactType type) async {
    if (type == ContactType.primary) {
      return await _fetchAndCachePrimaryContacts();
    } else if (type == ContactType.all) {
      return await _fetchAndCacheAllContacts();
    } else {
      return await ContactService.getContacts();
    }
  }

  /// Fetch and cache primary contacts (initial load)
  static Future<List<Contact>> _fetchAndCachePrimaryContacts() async {
    try {
      final contacts = await ContactApiService.fetchPrimaryContacts();
      
      // Cache the contacts
      await ContactService.savePrimaryContacts(contacts);
      
      // Save timestamp and set initial data flag
      await ContactCacheService.saveLastFetchTimestamp(ContactType.primary);
      await ContactCacheService.setHasInitialData(true);
      
      return contacts;
    } catch (e) {
      // Try to load from cache if API fails
      final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
      if (cachedContacts.isEmpty) {
        throw Exception('Failed to load primary contacts and no cache available: $e');
      }
      return cachedContacts;
    }
  }

  // /// Fetch updated primary contacts using timed retrieval
  // static Future<List<Contact>> _fetchUpdatedPrimaryContacts() async {
  //   try {
  //     // Load cached contacts first
  //     final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
      
  //     // Get last fetch timestamp
  //     String? lastFetchTime = await ContactCacheService.getLastFetchTimestamp(ContactType.primary);
      
  //     if (lastFetchTime == null) {
  //       // If no timestamp, do a full fetch
  //       return await _fetchAndCachePrimaryContacts();
  //     }
      
  //     // Fetch updates
  //     final updatedContacts = await ContactApiService.fetchUpdatedPrimaryContacts(lastFetchTime);
      
  //     if (updatedContacts.isEmpty) {
  //       // No updates, return cached data
  //       return cachedContacts;
  //     }
      
  //     // Merge updated contacts with cached ones
  //     final mergedContacts = _mergeContacts(cachedContacts, updatedContacts);
      
  //     // Update cache and timestamp
  //     await ContactService.savePrimaryContacts(mergedContacts);
  //     await ContactCacheService.saveLastFetchTimestamp(ContactType.primary);
      
  //     return mergedContacts;
  //   } catch (e) {
  //     // Return cached contacts if update fails
  //     final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
  //     if (cachedContacts.isEmpty) {
  //       throw Exception('Failed to update primary contacts and no cache available: $e');
  //     }
  //     throw Exception('Failed to update primary contacts: $e (using cached data)');
  //   }
  // }

  /// Fetch and cache all contacts (initial load)
  static Future<List<Contact>> _fetchAndCacheAllContacts() async {
    try {
      final contacts = await ContactApiService.fetchAllContacts();
      
      // Cache all contacts
      await ContactService.saveAllContacts(contacts);
      
      // Save timestamp and set initial data flag
      await ContactCacheService.saveLastFetchTimestamp(ContactType.all);
      await ContactCacheService.setHasInitialData(true);
      
      // Filter out primary contacts for display
      return contacts.where((contact) => !contact.isPrimary).toList();
    } catch (e) {
      // Try to load from cache if API fails
      final cachedContacts = await ContactService.getAllContactsFromStorage();
      if (cachedContacts.isEmpty) {
        throw Exception('Failed to load all contacts and no cache available: $e');
      }
      // Filter out primary contacts
      return cachedContacts.where((contact) => !contact.isPrimary).toList();
    }
  }

  // /// Fetch updated all contacts using timed retrieval
  // static Future<List<Contact>> _fetchUpdatedAllContacts() async {
  //   try {
  //     // Load cached contacts first
  //     final cachedContacts = await ContactService.getAllContactsFromStorage();
      
  //     // Get last fetch timestamp
  //     String? lastFetchTime = await ContactCacheService.getLastFetchTimestamp(ContactType.all);
      
  //     if (lastFetchTime == null) {
  //       // If no timestamp, do a full fetch
  //       return await _fetchAndCacheAllContacts();
  //     }
      
  //     // Fetch updates
  //     final updatedContacts = await ContactApiService.fetchUpdatedAllContacts(lastFetchTime);
      
  //     if (updatedContacts.isEmpty) {
  //       // No updates, return filtered cached data
  //       return cachedContacts.where((contact) => !contact.isPrimary).toList();
  //     }
      
  //     // Merge updated contacts with cached ones
  //     final mergedContacts = _mergeContacts(cachedContacts, updatedContacts);
      
  //     // Update cache and timestamp
  //     await ContactService.saveAllContacts(mergedContacts);
  //     await ContactCacheService.saveLastFetchTimestamp(ContactType.all);
      
  //     // Filter out primary contacts for display
  //     return mergedContacts.where((contact) => !contact.isPrimary).toList();
  //   } catch (e) {
  //     // Return filtered cached contacts if update fails
  //     final cachedContacts = await ContactService.getAllContactsFromStorage();
  //     if (cachedContacts.isEmpty) {
  //       throw Exception('Failed to update all contacts and no cache available: $e');
  //     }
  //     throw Exception('Failed to update all contacts: $e (using cached data)');
  //   }
  // }

  /// Merge updated contacts with cached contacts
  static List<Contact> _mergeContacts(List<Contact> cachedContacts, List<Contact> updatedContacts) {
    // Create a map from cached contacts for easy lookup
    Map<String, Contact> contactMap = {
      for (var contact in cachedContacts) contact.id: contact
    };
    
    // Update or add new contacts
    for (var contact in updatedContacts) {
      contactMap[contact.id] = contact;
    }
    
    // Convert back to list
    return contactMap.values.toList();
  }
}