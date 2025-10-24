// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:saral_yatri/presentation/screens/qr_scanner_screen.dart';
// import '../widgets/ticket/qr_display.dart';
// // import '../screens/qr_scanner_screen.dart';
// import '../../data/models/ticket_model.dart';
// import '../../core/constants/app_colors.dart';

// class QRDemoScreen extends ConsumerStatefulWidget {
//   const QRDemoScreen({super.key});

//   @override
//   ConsumerState<QRDemoScreen> createState() => _QRDemoScreenState();
// }

// class _QRDemoScreenState extends ConsumerState<QRDemoScreen> {
//   Map<String, dynamic>? _scannedData;

//   // Sample ticket for demo
//   final TicketModel _sampleTicket = TicketModel(
//     id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
//     userId: 'USER-123',
//     busId: 'BUS-456',
//     busNumber: 'DL-1PC-1234',
//     routeId: 'ROUTE-789',
//     routeName: 'Connaught Place - AIIMS',
//     boardingStop: 'Connaught Place',
//     droppingStop: 'AIIMS',
//     originalFare: 25.0,
//     subsidyAmount: 5.0,
//     finalFare: 20.0,
//     paymentMethod: 'UPI',
//     paymentStatus: 'completed',
//     bookingTime: DateTime.now(),
//     expiryTime: DateTime.now().add(const Duration(hours: 2)),
//     qrCode: '',
//     status: 'active',
//     isVerified: false,
//   );

//   void _openScanner() async {
//     final result = await Navigator.of(context).push<Map<String, dynamic>>(
//       MaterialPageRoute(
//         builder: (context) => QRScannerScreen(
//           title: 'Scan Ticket QR',
//           onTicketScanned: (data) {
//             setState(() {
//               _scannedData = data;
//             });
//           },
//         ),
//       ),
//     );

//     if (result != null) {
//       setState(() {
//         _scannedData = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR System Demo'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // QR Generation Section
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.qr_code, color: AppColors.primary),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'QR Code Generation',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Sample ticket with generated QR code:',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     QRDisplayWidget(ticket: _sampleTicket),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // QR Scanning Section
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.qr_code_scanner, color: AppColors.primary),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'QR Code Scanner',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Scan a ticket QR code to verify:',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: _openScanner,
//                       icon: const Icon(Icons.camera_alt),
//                       label: const Text('Open Scanner'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Scanned Data Display
//             if (_scannedData != null)
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.check_circle, color: AppColors.success),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Scanned QR Data',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[50],
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildDataRow('Ticket ID', _scannedData!['ticket_id']),
//                             _buildDataRow('User ID', _scannedData!['user_id']),
//                             _buildDataRow('Bus ID', _scannedData!['bus_id']),
//                             _buildDataRow('Route ID', _scannedData!['route_id']),
//                             _buildDataRow(
//                               'Expires',
//                               DateTime.fromMillisecondsSinceEpoch(_scannedData!['expiry'])
//                                   .toString(),
//                             ),
//                             _buildDataRow(
//                               'Scanned At',
//                               DateTime.fromMillisecondsSinceEpoch(_scannedData!['timestamp'])
//                                   .toString(),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _scannedData = null;
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[300],
//                           foregroundColor: Colors.black,
//                         ),
//                         child: const Text('Clear'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 20),

//             // Instructions
//             Card(
//               color: Colors.blue[50],
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info, color: Colors.blue[700]),
//                         const SizedBox(width: 8),
//                         Text(
//                           'How to Test',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       '1. The QR code above contains sample ticket data\n'
//                       '2. Use the scanner to scan this QR code\n'
//                       '3. The scanned data will appear below\n'
//                       '4. QR codes are validated for expiry and format',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'monospace',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
