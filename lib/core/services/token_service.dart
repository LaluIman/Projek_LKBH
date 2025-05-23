import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Jumlah maksimum token yang diberikan per hari
  static const int MAX_DAILY_TOKENS = 3;

  // Cache lokal untuk menyimpan token agar tidak sering baca Firestore
  static final Map<String, Map<String, dynamic>> _tokenCache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};
  static const Duration CACHE_DURATION = Duration(minutes: 5); // Lama cache berlaku

  // Inisialisasi token user, atau reset token jika tanggal berubah
  Future<void> initializeOrResetTokens(String userId) async {
    try {
      String currentDate = _getCurrentDateString();

      // Ambil dokumen user dari Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        // Jika user belum ada, buat dokumen baru dengan token default
        Map<String, dynamic> newTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        await _firestore.collection('users').doc(userId).set({
          'dailyTokens': newTokenData
        }, SetOptions(merge: true));
        
        _tokenCache[userId] = newTokenData;
        _cacheTimestamp[userId] = DateTime.now();
        return;
      }

      // Ambil data user
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Cek apakah sudah ada field dailyTokens
      if (!userData.containsKey('dailyTokens')) {
        Map<String, dynamic> newTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        await _firestore.collection('users').doc(userId).update({
          'dailyTokens': newTokenData
        });

        _tokenCache[userId] = newTokenData;
        _cacheTimestamp[userId] = DateTime.now();
        return;
      }

      // Ambil data token saat ini
      Map<String, dynamic> existingTokenData = userData['dailyTokens'];
      String storedDate = existingTokenData['date'];

      // Reset token jika sudah berganti hari
      if (storedDate != currentDate) {
        Map<String, dynamic> newTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        await _firestore.collection('users').doc(userId).update({
          'dailyTokens': newTokenData
        });

        _tokenCache[userId] = newTokenData;
        _cacheTimestamp[userId] = DateTime.now();
      } else {
        // Jika masih hari yang sama, hanya update cache
        _tokenCache[userId] = existingTokenData;
        _cacheTimestamp[userId] = DateTime.now();
      }
    } catch (e) {
      print('Error initializing tokens: $e');
      throw Exception('Failed to initialize tokens');
    }
  }

  // Ambil token dari cache atau Firestore
  Future<Map<String, dynamic>> getUserTokens(String userId) async {
    try {
      String currentDate = _getCurrentDateString();

      // Gunakan cache jika masih valid
      if (_tokenCache.containsKey(userId) && _cacheTimestamp.containsKey(userId)) {
        DateTime lastCached = _cacheTimestamp[userId]!;
        Map<String, dynamic> cachedData = _tokenCache[userId]!;

        if (DateTime.now().difference(lastCached) < CACHE_DURATION &&
            cachedData['date'] == currentDate) {
          return cachedData;
        }
      }

      // Ambil data dari Firestore jika cache kosong/kadaluarsa
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        // Buat data default jika user tidak ditemukan
        Map<String, dynamic> defaultTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        await _firestore.collection('users').doc(userId).set({
          'dailyTokens': defaultTokenData
        }, SetOptions(merge: true));

        _tokenCache[userId] = defaultTokenData;
        _cacheTimestamp[userId] = DateTime.now();
        return defaultTokenData;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (!userData.containsKey('dailyTokens')) {
        Map<String, dynamic> defaultTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        await _firestore.collection('users').doc(userId).update({
          'dailyTokens': defaultTokenData
        });

        _tokenCache[userId] = defaultTokenData;
        _cacheTimestamp[userId] = DateTime.now();
        return defaultTokenData;
      }

      Map<String, dynamic> tokenData = userData['dailyTokens'];
      String storedDate = tokenData['date'];

      if (storedDate != currentDate) {
        Map<String, dynamic> newTokenData = {
          'date': currentDate,
          'tokensLeft': MAX_DAILY_TOKENS
        };
        await _firestore.collection('users').doc(userId).update({
          'dailyTokens': newTokenData
        });

        tokenData = newTokenData;
      }

      _tokenCache[userId] = tokenData;
      _cacheTimestamp[userId] = DateTime.now();

      return tokenData;
    } catch (e) {
      print('Error getting user tokens: $e');
      if (_tokenCache.containsKey(userId)) {
        return _tokenCache[userId]!;
      }
      return {
        'date': _getCurrentDateString(),
        'tokensLeft': 0
      };
    }
  }

  // Ambil token dari cache jika tersedia
  Map<String, dynamic>? getCachedTokens(String userId) {
    if (_tokenCache.containsKey(userId) && _cacheTimestamp.containsKey(userId)) {
      DateTime lastCached = _cacheTimestamp[userId]!;
      String currentDate = _getCurrentDateString();

      if (DateTime.now().difference(lastCached) < CACHE_DURATION &&
          _tokenCache[userId]!['date'] == currentDate) {
        return _tokenCache[userId];
      }
    }
    return null;
  }

  // Mengurangi 1 token dan kembalikan sisa token
  Future<int> consumeToken(String userId) async {
    try {
      Map<String, dynamic> tokenData = await getUserTokens(userId);
      int tokensLeft = tokenData['tokensLeft'];

      if (tokensLeft <= 0) return 0;

      tokensLeft--;

      Map<String, dynamic> newTokenData = {
        'date': _getCurrentDateString(),
        'tokensLeft': tokensLeft
      };

      await _firestore.collection('users').doc(userId).update({
        'dailyTokens': newTokenData
      });

      _tokenCache[userId] = newTokenData;
      _cacheTimestamp[userId] = DateTime.now();

      return tokensLeft;
    } catch (e) {
      print('Error consuming token: $e');
      throw Exception('Failed to consume token');
    }
  }

  // Cek apakah user masih memiliki token
  Future<bool> hasTokensAvailable(String userId) async {
    try {
      Map<String, dynamic> tokenData = await getUserTokens(userId);
      return tokenData['tokensLeft'] > 0;
    } catch (e) {
      print('Error checking tokens availability: $e');
      return false;
    }
  }

  // Hapus cache user (bisa digunakan untuk debug atau refresh paksa)
  void clearUserCache(String userId) {
    _tokenCache.remove(userId);
    _cacheTimestamp.remove(userId);
  }

  // Ambil tanggal sekarang dalam format yyyy-MM-dd
  String _getCurrentDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
