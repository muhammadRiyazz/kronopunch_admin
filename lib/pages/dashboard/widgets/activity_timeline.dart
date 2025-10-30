import 'package:flutter/material.dart';

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade600),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: const [
              _ActivityItem(
                icon: Icons.login_rounded,
                title: "Morning Check-in Started",
                subtitle: "156 employees checked in today",
                time: "9:00 AM",
                color: Colors.green,
              ),
              _ActivityItem(
                icon: Icons.warning_amber_rounded,
                title: "Late Arrivals Reported",
                subtitle: "6 employees arrived after 9:30 AM",
                time: "9:45 AM",
                color: Colors.orange,
              ),
              _ActivityItem(
                icon: Icons.people_alt_rounded,
                title: "Team Meeting Completed",
                subtitle: "Development team weekly sync",
                time: "11:00 AM",
                color: Colors.blue,
              ),
              _ActivityItem(
                icon: Icons.assignment_turned_in_rounded,
                title: "Project Milestone Achieved",
                subtitle: "Q4 targets completed ahead of schedule",
                time: "2:30 PM",
                color: Colors.purple,
              ),
              _ActivityItem(
                icon: Icons.celebration_rounded,
                title: "Employee Anniversary",
                subtitle: "John Smith - 3 years with company",
                time: "4:00 PM",
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}