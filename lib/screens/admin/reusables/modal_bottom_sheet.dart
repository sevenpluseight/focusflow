// import 'package:flutter/material.dart';
// import 'package:focusflow/models/models.dart';

// class UserRequestDetailsSheet extends StatelessWidget {
//   final UserModel user;

//   const UserRequestDetailsSheet({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // User Details
//             Text(
//               "Coach Request",
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "The following user wants to register as a coach:",
//               style: theme.textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 24),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: CircleAvatar(
//                 radius: 24,
//                 child: Icon(Icons.person), // Placeholder icon
//               ),
//               title: Text(
//                 user.username,
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               subtitle: Text(user.email, style: theme.textTheme.bodyLarge),
//             ),
//             const Divider(height: 32),

//             // Action Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       // TODO: Implement decline logic
//                       Navigator.pop(context); // Close the sheet
//                     },
//                     child: const Text("Decline"),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: theme.colorScheme.error,
//                       side: BorderSide(color: theme.colorScheme.error),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // TODO: Implement accept logic
//                       Navigator.pop(context); // Close the sheet
//                     },
//                     child: const Text("Accept"),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }
