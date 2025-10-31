// lib/pages/dashboard/layout/main_layout.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kronopunch/pages/dashboard/layout/side_menu.dart';
import 'package:kronopunch/pages/dashboard/layout/mobile_drawer.dart';
import 'package:kronopunch/pages/dashboard/sections/attendance_page.dart';
import 'package:kronopunch/pages/dashboard/sections/dashboard_page.dart';
import 'package:kronopunch/pages/dashboard/sections/department_page.dart';
import 'package:kronopunch/pages/dashboard/sections/employee_page.dart';
import 'package:kronopunch/pages/dashboard/sections/leave_request_page.dart';
import 'package:kronopunch/pages/dashboard/sections/report_page.dart';
import 'package:kronopunch/pages/dashboard/sections/settings_page.dart';
import 'package:kronopunch/services/firebase_service.dart';
import 'package:kronopunch/services/cache_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String?> _userData = {};
  bool _loadingUserData = true;

  final List<Widget> _pages = [
    const DashboardPage(),
    const EmployeePage(),
    const AttendancePage(),
    const LeaveRequestPage(),
    const DepartmentPage(),
    const ReportsPage(),
    const SettingsPage(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Employees',
    'Attendance',
    'Leave Requests',
    'Departments',
    'Reports',
    'Settings',
  ];

  final List<String> _shortTitles = const [
    'Dashboard',
    'Employees',
    'Attendance',
    'Leave',
    'Departments',
    'Reports',
    'Settings',
  ];

  final List<IconData> _headerIcons = const [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.access_time_filled_rounded,
    Icons.request_page_rounded,
    Icons.apartment_rounded,
    Icons.analytics_rounded,
    Icons.settings_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await CacheService.getLoginData();
      final user = FirebaseAuth.instance.currentUser;
      
      setState(() {
        _userData = data;
        // If cache is empty but user is logged in, use Firebase data
        if (_userData.isEmpty && user != null) {
          _userData = {
            'email': user.email,
            'name': user.displayName ?? user.email?.split('@').first ?? 'User',
            'companyCode': 'Company',
            'role': 'Admin',
          };
        }
        _loadingUserData = false;
      });
    } catch (e) {
      setState(() {
        _loadingUserData = false;
      });
    }
  }

  void _onMenuSelect(int index) {
    if (index == _selectedIndex) {
      if (MediaQuery.of(context).size.width < 600) {
        _scaffoldKey.currentState?.closeDrawer();
      } 
      else if (MediaQuery.of(context).size.width < 768) {
        setState(() => _isMenuExpanded = false);
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
      if (MediaQuery.of(context).size.width < 600) {
        _scaffoldKey.currentState?.closeDrawer();
      }
      else if (MediaQuery.of(context).size.width < 768) {
        _isMenuExpanded = false;
      }
    });
  }

  void _toggleMenu() {
    if (MediaQuery.of(context).size.width < 600) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseService.logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/auth', 
                  (route) => false
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? MobileDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onMenuSelect,
        userData: _userData,
        onLogout: _logout,
        loading: _loadingUserData,
      ) : null,
      body: SafeArea(
        child: Row(
          children: [
            // Side Menu (persistent on desktop & tablet; disabled on mobile)
            if (!isMobile && !isTablet) 
              SideMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: _onMenuSelect,
                isExpanded: true,
                userData: _userData,
                onLogout: _logout,
                loading: _loadingUserData,
              ),
            
            // Tablet sidebar (togglable)
            if (isTablet)
              SideMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: _onMenuSelect,
                isExpanded: false,
                userData: _userData,
                onLogout: _logout,
                loading: _loadingUserData,
              ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Header
                  _buildHeader(isMobile, isTablet),
                  // Page content with animated transition
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            const Color(0xFFF8FAFC).withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isTablet) {
    return Container(
      height: isMobile ? 70 : 80,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title Section
          Row(
            children: [
              if (isMobile) ...[
                IconButton(
                  onPressed: _toggleMenu,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: Colors.grey.shade700,
                    size: 20
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: isMobile ? 12 : 16),
              ],
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _headerIcons[_selectedIndex],
                  color: const Color(0xFF1A237E),
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 200 : 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMobile ? _shortTitles[_selectedIndex] : _titles[_selectedIndex],
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A237E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isMobile) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getSubtitle(_selectedIndex),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // User Info & Actions
          if (!isMobile) _buildDesktopUserInfo(),
          if (isMobile) _buildMobileUserInfo(),
        ],
      ),
    );
  }

  Widget _buildDesktopUserInfo() {
    return Row(
      children: [
        _buildNotificationButton(),
        const SizedBox(width: 16),
        _buildUserProfile(),
      ],
    );
  }

  Widget _buildMobileUserInfo() {
    return Row(
      children: [
        _buildNotificationButton(isMobile: true),
        const SizedBox(width: 12),
        _buildUserProfile(isMobile: true),
      ],
    );
  }

  Widget _buildNotificationButton({bool isMobile = false}) {
    return Stack(
      children: [
        Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: Colors.grey.shade700,
            size: isMobile ? 20 : 22,
          ),
        ),
        Positioned(
          right: isMobile ? 3 : 4,
          top: isMobile ? 3 : 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile({bool isMobile = false}) {
    return GestureDetector(
      onTap: _logout,
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 18 : 20,
            backgroundColor: const Color(0xFF1A237E),
            child: _loadingUserData
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Text(
                    _userData['name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData['name'] ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Text(
                  _userData['role']?.toUpperCase() ?? 'USER',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.logout_rounded,
              color: Colors.grey,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }

  String _getSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Monitor your team performance and analytics';
      case 1:
        return 'Manage employee details and information';
      case 2:
        return 'Track attendance and time records';
      case 3:
        return 'Review and manage leave applications';
      case 4:
        return 'Organize departments and teams';
      case 5:
        return 'Generate reports and insights';
      case 6:
        return 'Configure system preferences';
      default:
        return 'Manage your workforce efficiently';
    }
  }
}