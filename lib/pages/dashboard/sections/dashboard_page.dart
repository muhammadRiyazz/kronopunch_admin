// lib/pages/dashboard/sections/dashboard_page.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kronopunch/pages/dashboard/widgets/dashboard_card.dart';
import 'package:kronopunch/pages/dashboard/widgets/activity_timeline.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildStatsGrid(context),
                const SizedBox(height: 28),
                _buildAnalyticsSection(context),
                const SizedBox(height: 28),
                _buildUpcomingEvents(),
                const SizedBox(height: 36),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, Admin! 👋",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's what's happening with your team today",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
                log(screenWidth.toString());

        int crossAxisCount;
        if (screenWidth >= 1400) {
          crossAxisCount = 5;
        } else if (screenWidth >= 1000) {
          crossAxisCount = 4;
        } else if (screenWidth >= 950) {
          crossAxisCount = 4;
        } else if (screenWidth >= 650) {
          crossAxisCount = 3;
        } else if (screenWidth >= 600) {
          crossAxisCount = 2;
        } else if (screenWidth >= 400) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.45,
          children: const [
            DashboardCard(
              title: 'Present Today',
              value: '142',
              subtitle: '91% attendance rate',
              icon: Icons.access_time_filled_rounded,
            ),
            DashboardCard(
              title: 'On Leave',
              value: '8',
              subtitle: '5% of workforce',
              icon: Icons.beach_access_rounded,
            ),
            DashboardCard(
              title: 'Late Arrivals',
              value: '6',
              subtitle: '4% of present staff',
              icon: Icons.watch_later_rounded,
            ),
            DashboardCard(
              title: 'Pending Approvals',
              value: '15',
              subtitle: 'Leaves & requests',
              icon: Icons.pending_actions_rounded,
            ),
            DashboardCard(
              title: 'Overtime Hours',
              value: '48',
              subtitle: 'This week total',
              icon: Icons.timer_rounded,
            ),
            DashboardCard(
              title: 'Departments',
              value: '8',
              subtitle: 'Active teams',
              icon: Icons.apartment_rounded,
            ),
            DashboardCard(
              title: 'Avg. Hours',
              value: '8.2',
              subtitle: 'Daily per employee',
              icon: Icons.av_timer_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      height: 380,
                      decoration: _panelDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: const ActivityTimeline(),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: _panelDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: _buildQuickActions(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
             
            ],
          );
        } else {
          return Column(
            children: [
              Container(
                height: 320,
                decoration: _panelDecoration(),
                padding: const EdgeInsets.all(16),
                child: const ActivityTimeline(),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: _panelDecoration(),
                padding: const EdgeInsets.all(16),
                child: _buildQuickActions(context),
              ),
            ],
          );
        }
      },
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 6)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    // grid adjusts based on width
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (width < 700) crossAxisCount = 2;
    if (width < 420) crossAxisCount = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.6,
          children: [
            _QuickActionButton(
              icon: Icons.add_circle_rounded,
              label: 'Add Employee',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.download_rounded,
              label: 'Export Report',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.calendar_today_rounded,
              label: 'Schedule',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.notifications_active_rounded,
              label: 'Announce',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildMiniStats() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text("Team Performance", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
  //       const SizedBox(height: 12),
  //       Text("Avg productivity: 87%", style: TextStyle(color: Colors.grey.shade600)),
  //       const SizedBox(height: 8),
  //       LinearProgressIndicator(value: 0.87),
  //       const SizedBox(height: 18),
  //       Text("New hires: 3", style: TextStyle(color: Colors.grey.shade600)),
  //       const SizedBox(height: 8),
  //       Text("Open requisitions: 2", style: TextStyle(color: Colors.grey.shade600)),
  //     ],
  //   );
  // }

  Widget _buildUpcomingEvents() {
    final events = [
      {'title': 'Team Meeting', 'time': 'Today, 2:00 PM', 'type': 'Meeting'},
      {'title': 'Project Deadline', 'time': 'Tomorrow', 'type': 'Deadline'},
      {'title': 'Company Workshop', 'time': 'Dec 15, 10:00 AM', 'type': 'Workshop'},
      {'title': 'Performance Review', 'time': 'Dec 18, 3:00 PM', 'type': 'Review'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_rounded, color: Colors.purple.shade700),
            const SizedBox(width: 12),
            Text(
              "Upcoming Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...events.map((e) => _EventItem(title: e['title']!, time: e['time']!, type: e['type']!)),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      color: color.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  final String title;
  final String time;
  final String type;

  const _EventItem({required this.title, required this.time, required this.type});

  Color getTypeColor() {
    switch (type) {
      case 'Meeting':
        return Colors.blue;
      case 'Deadline':
        return Colors.red;
      case 'Workshop':
        return Colors.green;
      case 'Review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getTypeColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 44, decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(type, style: TextStyle(color: typeColor, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
