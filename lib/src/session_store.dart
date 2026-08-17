import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class SessionStore {
  static const _historyKey = 'interview_history';
  static const _userKey = 'candidate_name';
  static const _emailKey = 'candidate_email';
  static const _passwordKey = 'candidate_password';
  static const _signedInKey = 'signed_in';
  Future<String?> loadUser() async =>
      (await SharedPreferences.getInstance()).getString(_userKey);
  Future<void> saveUser(String name) async =>
      (await SharedPreferences.getInstance()).setString(_userKey, name);

  Future<bool> hasAccount() async =>
      (await SharedPreferences.getInstance()).containsKey(_emailKey);

  Future<bool> isSignedIn() async =>
      (await SharedPreferences.getInstance()).getBool(_signedInKey) ?? false;

  Future<void> createAccount(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, name);
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_signedInKey, true);
  }

  Future<String?> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final matches =
        prefs.getString(_emailKey) == email.trim().toLowerCase() &&
        prefs.getString(_passwordKey) == password;
    if (!matches) return null;
    await prefs.setBool(_signedInKey, true);
    return prefs.getString(_userKey);
  }

  Future<void> signOut() async =>
      (await SharedPreferences.getInstance()).setBool(_signedInKey, false);
  Future<List<Map<String, dynamic>>> loadHistory() async {
    final raw =
        (await SharedPreferences.getInstance()).getStringList(_historyKey) ??
        [];
    return raw.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  Future<void> saveSession(InterviewSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    history.insert(0, jsonEncode(session.toJson()));
    await prefs.setStringList(_historyKey, history.take(20).toList());
  }
}
