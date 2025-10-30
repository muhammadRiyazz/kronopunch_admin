// lib/pages/dashboard/layout/main_layout.dart
import 'package:flutter/material.dart';
import 'package:kronopunch/pages/dashboard/layout/side_menu.dart';
import 'package:kronopunch/pages/dashboard/layout/mobile_drawer.dart';
import 'package:kronopunch/pages/dashboard/sections/attendance_page.dart';
import 'package:kronopunch/pages/dashboard/sections/dashboard_page.dart';
import 'package:kronopunch/pages/dashboard/sections/department_page.dart';
import 'package:kronopunch/pages/dashboard/sections/employee_page.dart';
import 'package:kronopunch/pages/dashboard/sections/leave_request_page.dart';
import 'package:kronopunch/pages/dashboard/sections/report_page.dart';
import 'package:kronopunch/pages/dashboard/sections/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _onMenuSelect(int index) {
    if (index == _selectedIndex) {
      // If already selected, close drawer on mobile
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
      // Close drawer on mobile after selection
      if (MediaQuery.of(context).size.width < 600) {
        _scaffoldKey.currentState?.closeDrawer();
      }
      // Close sidebar on tablet after selection
      else if (MediaQuery.of(context).size.width < 768) {
        _isMenuExpanded = false;
      }
    });
  }

  void _toggleMenu() {
    if (MediaQuery.of(context).size.width < 600) {
      _scaffoldKey.currentState?.openDrawer();
    } 
    // else {
    //   setState(() => _isMenuExpanded = !_isMenuExpanded);
    // }
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
              ),
            

            // // Tablet sidebar (togglable)
            if (isTablet )
              SideMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: _onMenuSelect,
                isExpanded: false,
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

      // // Floating Action Button for tablet menu
      // floatingActionButton: isTablet
      //     ? FloatingActionButton(
      //         onPressed: _toggleMenu,
      //         backgroundColor: const Color(0xFF1A237E),
      //         child: Icon(
      //           _isMenuExpanded ? Icons.close : Icons.menu,
      //           color: Colors.white,
      //         ),
      //         mini: true,
      //       )
      //     : null,
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
              if (isMobile ) ...[
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
                    if (!isMobile ) ...[
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
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF1A237E),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
        ),
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

  Widget _buildUserProfile() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF1A237E),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
       
        // Icon(
        //   Icons.arrow_drop_down_rounded,
        //   color: Colors.grey.shade600,
        // ),
      ],
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