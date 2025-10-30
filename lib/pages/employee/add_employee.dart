// import 'package:flutter/material.dart';
// import '../../services/firebase_service.dart';
// import '../../models/employee_model.dart';

// class AddEmployeeDialog extends StatefulWidget {
//   final String companyId;

//   const AddEmployeeDialog({required this.companyId, super.key});

//   @override
//   State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
// }

// class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _roleController = TextEditingController(text: 'employee');
//   bool _loading = false;

//   Future<void> _addEmployee() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter employee name')),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final employee = Employee(
//         name: _nameController.text.trim(),
//         email: _emailController.text.trim(),
//         role: _roleController.text.trim(),
//         createdAt: DateTime.now(),
//         companyId: widget.companyId,
//       );

//       await FirebaseService.addEmployee(widget.companyId, employee);

//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Employee added successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _roleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Row(
//         children: [
//           Icon(Icons.person_add, color: Theme.of(context).primaryColor),
//           SizedBox(width: 8),
//           Text('Add Employee'),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Full Name',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _roleController.text,
//               decoration: InputDecoration(
//                 labelText: 'Role',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//               items: ['employee', 'manager', 'admin']
//                   .map((role) => DropdownMenuItem(
//                         value: role,
//                         child: Text(role[0].toUpperCase() + role.substring(1)),
//                       ))
//                   .toList(),
//               onChanged: (value) {
//                 _roleController.text = value!;
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _loading ? null : () => Navigator.of(context).pop(),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _loading ? null : _addEmployee,
//           child: _loading
//               ? SizedBox(
//                   height: 16,
//                   width: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//               : Text('Add Employee'),
//         ),
//       ],
//     );
//   }
// }