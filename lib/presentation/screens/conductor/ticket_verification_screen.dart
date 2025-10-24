import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/qr/qr_scanner_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/ticket_service.dart';
import '../../../data/models/ticket_model.dart';

class TicketVerificationScreen extends ConsumerStatefulWidget {
  const TicketVerificationScreen({super.key});

  @override
  ConsumerState<TicketVerificationScreen> createState() =>
      _TicketVerificationScreenState();
}

class _TicketVerificationScreenState
    extends ConsumerState<TicketVerificationScreen> {
  TicketModel? _scannedTicket;
  String? _errorMessage;
  bool _isVerifying = false;

  void _onQRScanned(Map<String, dynamic> qrData) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Verify ticket with backend
      final ticketService = ref.read(ticketServiceProvider);
      final ticket = await ticketService.verifyTicket(qrData['ticket_id']);

      if (ticket != null) {
        setState(() {
          _scannedTicket = ticket;
          _isVerifying = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Ticket not found or invalid';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error verifying ticket: $e';
        _isVerifying = false;
      });
    }
  }

  void _onScanError(String error) {
    setState(() {
      _errorMessage = error;
    });
  }

  void _resetScanner() {
    setState(() {
      _scannedTicket = null;
      _errorMessage = null;
      _isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Verify Ticket'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_scannedTicket != null || _errorMessage != null)
            IconButton(
              onPressed: _resetScanner,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner view
          if (_scannedTicket == null && _errorMessage == null)
            Column(
              children: [
                Expanded(
                  child: QRScannerWidget(
                    onQRScanned: _onQRScanned,
                    onError: _onScanError,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black,
                  child: const Text(
                    'Position the passenger\'s QR code within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

          // Verification result
          if (_scannedTicket != null) _buildVerificationResult(),

          // Error display
          if (_errorMessage != null) _buildErrorDisplay(),

          // Loading overlay
          if (_isVerifying)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Verifying ticket...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationResult() {
    final ticket = _scannedTicket!;
    final isValid = ticket.isActive && !ticket.isExpired;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status indicator
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isValid ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isValid ? Icons.check : Icons.close,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                isValid ? 'VALID TICKET' : 'INVALID TICKET',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isValid ? AppColors.success : AppColors.error,
                ),
              ),

              const SizedBox(height: 30),

              // Ticket details
              _buildTicketDetails(ticket),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Scan Another'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (isValid)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _markTicketAsUsed(ticket),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Mark as Used'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketDetails(TicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Ticket ID', ticket.id),
          _buildDetailRow('Bus Number', ticket.busNumber),
          _buildDetailRow('Route', ticket.routeName),
          _buildDetailRow('From', ticket.boardingStop),
          _buildDetailRow('To', ticket.droppingStop),
          _buildDetailRow('Fare', '₹${ticket.finalFare.toStringAsFixed(2)}'),
          _buildDetailRow('Status', ticket.status.toUpperCase()),
          _buildDetailRow('Expires', _formatDateTime(ticket.expiryTime)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SCAN ERROR',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _resetScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _markTicketAsUsed(TicketModel ticket) async {
    try {
      final ticketService = ref.read(ticketServiceProvider);
      await ticketService.markTicketAsUsed(ticket.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket marked as used'),
            backgroundColor: AppColors.success,
          ),
        );
        _resetScanner();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
