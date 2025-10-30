// lib/pages/dashboard/layout/side_menu.dart
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isExpanded;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    // final isMobile = MediaQuery.of(context).size.width < 768;
    // final width = isMobile ? 280.0 : ();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 258.0 : 90.0,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          _buildLogoSection(isExpanded),
          const SizedBox(height: 12),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuSection('MAIN', isExpanded),
                  const SizedBox(height: 8),
                  _buildMenuSection('MANAGEMENT', isExpanded),
                  const SizedBox(height: 8),
                  _buildMenuSection('SYSTEM', isExpanded),
                ],
              ),
            ),
          ),

          // Footer
          _buildFooter(isExpanded),
        ],
      ),
    );
  }

  Widget _buildLogoSection(bool isExpanded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KronoPunch',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Attendance System',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, bool isExpanded) {
    final sectionItems = _getSectionItems(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpanded) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        ...sectionItems.map((item) => _buildMenuItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              index: item['index'] as int,
              isExpanded: isExpanded,
            )),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isExpanded,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.18)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isExpanded) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Column(
        children: [
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Contact support',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright_rounded,
                color: Colors.white54,
                size: 12,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 6),
                const Text(
                  '2025 KronoPunch v2.0',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSectionItems(String section) {
    switch (section) {
      case 'MAIN':
        return [
          {'icon': Icons.dashboard_rounded, 'label': 'Dashboard', 'index': 0},
          {'icon': Icons.analytics_rounded, 'label': 'Reports', 'index': 5},
        ];
      case 'MANAGEMENT':
        return [
          {'icon': Icons.people_alt_rounded, 'label': 'Employees', 'index': 1},
          {'icon': Icons.access_time_filled_rounded, 'label': 'Attendance', 'index': 2},
          {'icon': Icons.request_page_rounded, 'label': 'Leave Requests', 'index': 3},
          {'icon': Icons.apartment_rounded, 'label': 'Departments', 'index': 4},
        ];
      case 'SYSTEM':
        return [
          {'icon': Icons.settings_rounded, 'label': 'Settings', 'index': 6},
        ];
      default:
        return [];
    }
  }
}
