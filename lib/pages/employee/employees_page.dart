// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:kronopunch/pages/employee/add_employee.dart';
// import '../../services/firebase_service.dart';

// class EmployeesPage extends StatelessWidget {
//   final String companyId;

//   const EmployeesPage({required this.companyId, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Employees'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseService.getEmployeesStream(companyId),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           final employees = snapshot.data!.docs;

//           if (employees.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
//                   SizedBox(height: 16),
//                   Text(
//                     'No Employees Yet',
//                     style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Add your first employee to get started',
//                     style: TextStyle(color: Colors.grey.shade500),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: EdgeInsets.all(16),
//             itemCount: employees.length,
//             itemBuilder: (context, index) {
//               final employee = employees[index];
//               final data = employee.data() as Map<String, dynamic>;

//               return Card(
//                 elevation: 2,
//                 margin: EdgeInsets.only(bottom: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
//                     child: Icon(Icons.person, color: Theme.of(context).primaryColor),
//                   ),
//                   title: Text(
//                     data['name'] ?? 'Unknown',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(data['email'] ?? ''),
//                       SizedBox(height: 4),
//                       Chip(
//                         label: Text(
//                           (data['role'] ?? 'employee').toUpperCase(),
//                           style: TextStyle(fontSize: 10, color: Colors.white),
//                         ),
//                         backgroundColor: Theme.of(context).primaryColor,
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         visualDensity: VisualDensity.compact,
//                       ),
//                     ],
//                   ),
//                   trailing: Icon(Icons.arrow_forward_ios, size: 16),
//                   onTap: () {
//                     // Show employee details
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (_) => AddEmployeeDialog(companyId: companyId),
//           );
//         },
//         child: Icon(Icons.add),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//     );
//   }
// }