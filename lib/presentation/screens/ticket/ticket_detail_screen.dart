import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:qr/qr.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/models/enhanced_ticket_display_model.dart';
import '../../../core/services/data_resolution_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/ticket/ticket_card.dart';
import 'qr_ticket_screen.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;
  final EnhancedTicketDisplayModel? enhancedTicket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
    this.enhancedTicket,
  });

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  EnhancedTicketDisplayModel? _resolvedTicket;
  bool _isLoadingNames = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticket.isActive) {
      _enableScreenProtection();
    }

    // If we don't have enhanced ticket data, try to resolve names
    if (widget.enhancedTicket == null) {
      _resolveTicketNames();
    } else {
      _resolvedTicket = widget.enhancedTicket;
    }
  }

  @override
  void dispose() {
    if (widget.ticket.isActive) {
      _disableScreenProtection();
    }
    super.dispose();
  }

  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _disableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      // Handle silently
    }
  }

  void _showEnhancedQRTicket() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrTicketScreen(
          ticket: widget.ticket,
          enhancedDisplay: _resolvedTicket,
        ),
      ),
    );
  }

  Future<void> _resolveTicketNames() async {
    if (widget.ticket.boardingStationId == null ||
        widget.ticket.destinationStationId == null) {
      // Create enhanced ticket from existing data if no station IDs
      _resolvedTicket = EnhancedTicketDisplayModel.fromTicket(widget.ticket);
      return;
    }

    setState(() {
      _isLoadingNames = true;
    });

    try {
      final resolvedData = await DataResolutionService.resolveTicketData(
        boardingStationId: widget.ticket.boardingStationId!,
        destinationStationId: widget.ticket.destinationStationId!,
        busId: widget.ticket.busId,
        routeId: widget.ticket.routeId,
      );

      setState(() {
        _resolvedTicket = EnhancedTicketDisplayModel.withResolvedNames(
          ticket: widget.ticket,
          boardingStationName: resolvedData['boardingStation']!,
          destinationStationName: resolvedData['destinationStation']!,
          busNumber: resolvedData['busNumber']!,
          routeName: resolvedData['routeName']!,
        );
        _isLoadingNames = false;
      });
    } catch (e) {
      setState(() {
        _resolvedTicket = EnhancedTicketDisplayModel.fromTicket(widget.ticket);
        _isLoadingNames = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ticket Details',
        actions: [
          if (widget.ticket.isActive) ...[
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                // Convert to enhanced ticket and show QR screen
                _showEnhancedQRTicket();
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature will be available soon'),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: widget.ticket.isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.ticket.isActive ? Icons.check_circle : Icons.error,
                    color: widget.ticket.isActive
                        ? AppColors.success
                        : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.ticket.isActive ? 'ACTIVE TICKET' : 'EXPIRED TICKET',
                    style: TextStyle(
                      color: widget.ticket.isActive
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ticket card with enhanced data
                  TicketCardWidget(
                    ticket: widget.ticket,
                    enhancedTicket: _resolvedTicket,
                  ),

                  const SizedBox(height: 16),

                  // QR code (only for active tickets)
                  if (widget.ticket.isActive) ...[
                    _buildQRCodeSection(),
                    const SizedBox(height: 16),
                  ],

                  // Journey details
                  _buildJourneyDetails(),

                  const SizedBox(height: 16),

                  // Fare breakdown
                  _buildFareBreakdown(),

                  const SizedBox(height: 16),

                  // Booking information
                  _buildBookingInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyDetails() {
    final displayTicket =
        _resolvedTicket ?? EnhancedTicketDisplayModel.fromTicket(widget.ticket);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Journey Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_isLoadingNames) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else if (displayTicket.isDataResolved) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Bus Number', displayTicket.busNumber),
            if (displayTicket.isDataResolved &&
                displayTicket.routeName.isNotEmpty &&
                !displayTicket.routeName.startsWith('Route'))
              _buildDetailRow('Route', displayTicket.routeName),
            _buildDetailRow('From', displayTicket.boardingStationName),
            _buildDetailRow('To', displayTicket.destinationStationName),
            _buildDetailRow('Travel Date',
                '${widget.ticket.bookingTime.day}/${widget.ticket.bookingTime.month}/${widget.ticket.bookingTime.year}'),
            _buildDetailRow(
                'Valid Until',
                '${widget.ticket.expiryTime.day}/${widget.ticket.expiryTime.month}/${widget.ticket.expiryTime.year} '
                    '${widget.ticket.expiryTime.hour}:${widget.ticket.expiryTime.minute.toString().padLeft(2, '0')}'),
            if (widget.ticket.ticketNumber != null)
              _buildDetailRow('Ticket Number', widget.ticket.ticketNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildFareBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fare Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Original Fare',
                '₹${widget.ticket.originalFare.toStringAsFixed(2)}'),
            if (widget.ticket.subsidyAmount > 0)
              _buildDetailRow('Subsidy Amount',
                  '-₹${widget.ticket.subsidyAmount.toStringAsFixed(2)}',
                  color: AppColors.success),
            if (widget.ticket.taxAmount != null && widget.ticket.taxAmount! > 0)
              _buildDetailRow('Tax Amount',
                  '₹${widget.ticket.taxAmount!.toStringAsFixed(2)}'),
            const Divider(),
            _buildDetailRow('Final Amount',
                '₹${widget.ticket.finalFare.toStringAsFixed(2)}',
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Ticket ID', widget.ticket.id),
            if (widget.ticket.ticketNumber != null)
              _buildDetailRow('Ticket Number', widget.ticket.ticketNumber!),
            _buildDetailRow(
                'Booking Time',
                '${widget.ticket.bookingTime.day}/${widget.ticket.bookingTime.month}/${widget.ticket.bookingTime.year} '
                    '${widget.ticket.bookingTime.hour}:${widget.ticket.bookingTime.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow(
                'Payment Method', widget.ticket.paymentMethod.toUpperCase()),
            if (widget.ticket.transactionId != null)
              _buildDetailRow('Transaction ID', widget.ticket.transactionId!),
            _buildDetailRow('Status', widget.ticket.status.toUpperCase(),
                color: widget.ticket.isActive
                    ? AppColors.success
                    : AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.ticket.isExpired ? AppColors.error : AppColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (widget.ticket.isExpired ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code,
                color: widget.ticket.isExpired
                    ? AppColors.error
                    : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Show this QR to Conductor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.ticket.isExpired
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // QR Code display using actual API data
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if ((widget.ticket.encryptedToken?.isNotEmpty ?? false) &&
                    !widget.ticket.isExpired)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildQRCodeFromData(widget.ticket.encryptedToken!),
                  )
                else if (widget.ticket.qrCode.isNotEmpty &&
                    !widget.ticket.isExpired)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildQRCodeFromData(widget.ticket.qrCode),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.ticket.isExpired
                            ? Icons.error
                            : Icons.error_outline,
                        size: 48,
                        color: widget.ticket.isExpired
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.ticket.isExpired
                            ? 'QR CODE EXPIRED'
                            : 'QR CODE ERROR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.ticket.isExpired
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                // Expired overlay
                if (widget.ticket.isExpired)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'EXPIRED',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ticket status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.ticket.isExpired
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.ticket.isExpired
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              widget.ticket.isExpired ? 'EXPIRED' : 'VALID TICKET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.ticket.isExpired
                    ? AppColors.error
                    : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeFromData(String qrData) {
    // Use the actual QR data from the API
    return Container(
      width: 180,
      height: 180,
      child: CustomPaint(
        size: const Size(180, 180),
        painter: _QRCodePainter(data: qrData),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: color ??
                    (isTotal ? AppColors.primary : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QRCodePainter extends CustomPainter {
  final String data;

  _QRCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

      final qrImage = QrImage(qrCode);
      final pixelSize = size.width / qrImage.moduleCount;

      final paint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      for (int x = 0; x < qrImage.moduleCount; x++) {
        for (int y = 0; y < qrImage.moduleCount; y++) {
          if (qrImage.isDark(y, x)) {
            final rect = Rect.fromLTWH(
              x * pixelSize,
              y * pixelSize,
              pixelSize,
              pixelSize,
            );
            canvas.drawRect(rect, paint);
          }
        }
      }
    } catch (e) {
      // Fallback: draw error message
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'QR ERROR',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
