import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/services.dart'; // Import the Service

class AdminUsersProvider with ChangeNotifier {
  final UserService _userService;

  // allows injection
  AdminUsersProvider({UserService? userService})
    : _userService = userService ?? UserService();

  //states
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  String _searchQuery = ''; //for both search coaches requests and users
  String _selectedRoleFilter = 'all'; //just in case needed anywhere else

  // UI state
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;

  // manage stream connection
  StreamSubscription<List<UserModel>>? _usersSubscription;

  // getters
  List<UserModel> get allUsers => _allUsers;
  List<UserModel> get filteredUsers => _filteredUsers;
  String get searchQuery => _searchQuery;
  String get selectedRoleFilter => _selectedRoleFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _filteredUsers.isEmpty && !_isLoading;

  // initialize the provider, call from view
  void ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;

    _startListeningToUsers();
  }

  // load the users data
  void _startListeningToUsers() {
    _usersSubscription = _userService.getAllUsers().listen(
      (users) {
        _allUsers = users;
        _applyFilters();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners(); //rebuild UI
      },
      onError: (error) {
        _errorMessage = 'Failed to load users: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void reset() {
    _usersSubscription?.cancel();
    _usersSubscription = null;

    _allUsers = [];
    _filteredUsers = [];
    _searchQuery = '';
    _selectedRoleFilter = 'all';
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;

    notifyListeners();
  }

  // filter the list based on states
  void _applyFilters() {
    _filteredUsers = _allUsers.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.username.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery);

      final matchesRole =
          _selectedRoleFilter == 'all' || user.role == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  // update _filteredUsers state + rebuild UI widget
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  // clear _searchQuery state + update _filteredUsers state + rebuild widget
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // update _selectedRoleFilter state + update _filteredUsers state + rebuild widget
  void updateRoleFilter(String role) {
    _selectedRoleFilter = role;
    _applyFilters();
    notifyListeners();
  }

  // change user role
  Future<bool> changeUserRole(String uid, String newRole) async {
    try {
      await _userService.updateUserRole(uid, newRole);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update role: $e';
      notifyListeners(); //ask UI to show error screen or widget
      return false;
    }
  }

  // delete user
  Future<bool> deleteUser(String uid) async {
    try {
      await _userService.deleteUser(uid);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}
