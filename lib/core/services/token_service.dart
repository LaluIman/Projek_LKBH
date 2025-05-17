import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Maximum tokens per day
  static const int MAX_DAILY_TOKENS = 3;
  
  // Cache for token data to avoid repeated Firestore calls
  static Map<String, Map<String, dynamic>> _tokenCache = {};
  static Map<String, DateTime> _cacheTimestamp = {};
  static const Duration CACHE_DURATION = Duration(minutes: 5);
  
  // Refresh state tracking
  static Map<String, bool> _isRefreshing = {};

  // Initialize tokens for a new user or reset if date changed
  Future<void> initializeOrResetTokens(String userId) async {
    try {
      // Get user document
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        // If user document doesn't exist, create it with tokens
        await _firestore.collection('users').doc(userId).set({
          'dailyTokens': {
            'date': _getCurrentDateString(),
            'tokensLeft': MAX_DAILY_TOKENS
          }
        }, SetOptions(merge: true));
        
        // Update cache
        _tokenCache[userId] = {
          'date': _getCurrentDateString(),
          'tokensLeft': MAX_DAILY_TOKENS
        };
        _cacheTimestamp[userId] = DateTime.now();
        return;
      }
      
      // Get user data
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Check if dailyTokens exists and if date has changed
      if (!userData.containsKey('dailyTokens') || 
          userData['dailyTokens']['date'] != _getCurrentDateString()) {
        // Reset tokens for new day
        Map<String, dynamic> newTokenData = {
          'date': _getCurrentDateString(),
          'tokensLeft': MAX_DAILY_TOKENS
        };
        
        await _firestore.collection('users').doc(userId).update({
          'dailyTokens': newTokenData
        });
        
        // Update cache
        _tokenCache[userId] = newTokenData;
        _cacheTimestamp[userId] = DateTime.now();
      } else {
        // Update cache with existing data
        _tokenCache[userId] = userData['dailyTokens'];
        _cacheTimestamp[userId] = DateTime.now();
      }
    } catch (e) {
      print('Error initializing tokens: $e');
      throw Exception('Failed to initialize tokens');
    }
  }

  // Get tokens for current user with caching
  Future<Map<String, dynamic>> getUserTokens(String userId, {bool forceRefresh = false}) async {
    try {
      // Set refreshing state
      _isRefreshing[userId] = true;
      
      // Check if we have recent cached data
      if (!forceRefresh && _tokenCache.containsKey(userId) && _cacheTimestamp.containsKey(userId)) {
        DateTime lastCached = _cacheTimestamp[userId]!;
        if (DateTime.now().difference(lastCached) < CACHE_DURATION) {
          // Check if date has changed since cache
          String currentDate = _getCurrentDateString();
          if (_tokenCache[userId]!['date'] == currentDate) {
            // Return cached data if it's fresh and from the same day
            _isRefreshing[userId] = false;
            return _tokenCache[userId]!;
          }
        }
      }
      
      // If no cache or cache is stale/outdated, get from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        Map<String, dynamic> defaultTokenData = {
          'date': _getCurrentDateString(),
          'tokensLeft': 0
        };
        _tokenCache[userId] = defaultTokenData;
        _cacheTimestamp[userId] = DateTime.now();
        _isRefreshing[userId] = false;
        return defaultTokenData;
      }
      
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      if (!userData.containsKey('dailyTokens')) {
        Map<String, dynamic> defaultTokenData = {
          'date': _getCurrentDateString(),
          'tokensLeft': 0
        };
        _tokenCache[userId] = defaultTokenData;
        _cacheTimestamp[userId] = DateTime.now();
        _isRefreshing[userId] = false;
        return defaultTokenData;
      }
      
      // Check if date has changed and reset if needed
      Map<String, dynamic> tokenData = userData['dailyTokens'];
      String currentDate = _getCurrentDateString();
      
      if (tokenData['date'] != currentDate) {
        // Reset tokens for new day
        Map<String, dynamic> newTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        
        // Update in Firestore
        await _firestore.collection('users').doc(userId).update({
          'dailyTokens': newTokenData
        });
        
        tokenData = newTokenData;
      }
      
      // Update cache
      _tokenCache[userId] = tokenData;
      _cacheTimestamp[userId] = DateTime.now();
      _isRefreshing[userId] = false;
      
      return tokenData;
    } catch (e) {
      print('Error getting user tokens: $e');
      _isRefreshing[userId] = false;
      Map<String, dynamic> defaultTokenData = {
        'date': _getCurrentDateString(),
        'tokensLeft': 0
      };
      _tokenCache[userId] = defaultTokenData;
      _cacheTimestamp[userId] = DateTime.now();
      return defaultTokenData;
    }
  }

  // Get tokens quickly from cache (for UI updates)
  Map<String, dynamic>? getCachedTokens(String userId) {
    if (_tokenCache.containsKey(userId) && _cacheTimestamp.containsKey(userId)) {
      DateTime lastCached = _cacheTimestamp[userId]!;
      if (DateTime.now().difference(lastCached) < CACHE_DURATION) {
        return _tokenCache[userId];
      }
    }
    return null;
  }

  // Check if tokens are currently being refreshed
  bool isRefreshing(String userId) {
    return _isRefreshing[userId] ?? false;
  }

  // Consume one token and return remaining tokens
  Future<int> consumeToken(String userId) async {
    try {
      // Get current tokens (this will handle initialization/reset if needed)
      Map<String, dynamic> tokenData = await getUserTokens(userId);
      int tokensLeft = tokenData['tokensLeft'];
      
      if (tokensLeft <= 0) {
        return 0; // No tokens left
      }
      
      // Decrease token count
      tokensLeft--;
      
      // Update in Firestore
      Map<String, dynamic> newTokenData = {
        'date': _getCurrentDateString(),
        'tokensLeft': tokensLeft
      };
      
      await _firestore.collection('users').doc(userId).update({
        'dailyTokens': newTokenData
      });
      
      // Update cache immediately
      _tokenCache[userId] = newTokenData;
      _cacheTimestamp[userId] = DateTime.now();
      
      return tokensLeft;
    } catch (e) {
      print('Error consuming token: $e');
      throw Exception('Failed to consume token');
    }
  }

  // Check if user has tokens available
  Future<bool> hasTokensAvailable(String userId) async {
    try {
      Map<String, dynamic> tokenData = await getUserTokens(userId);
      return tokenData['tokensLeft'] > 0;
    } catch (e) {
      print('Error checking tokens availability: $e');
      return false;
    }
  }

  // Clear cache for a specific user (useful for debugging or manual refresh)
  void clearCache(String userId) {
    _tokenCache.remove(userId);
    _cacheTimestamp.remove(userId);
    _isRefreshing.remove(userId);
  }

  // Clear all cache
  void clearAllCache() {
    _tokenCache.clear();
    _cacheTimestamp.clear();
    _isRefreshing.clear();
  }

  // Force refresh tokens from server
  Future<Map<String, dynamic>> forceRefreshTokens(String userId) async {
    clearCache(userId);
    return await getUserTokens(userId, forceRefresh: true);
  }

  // Get current date in string format YYYY-MM-DD
  String _getCurrentDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}