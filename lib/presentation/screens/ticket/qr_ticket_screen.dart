import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/qr_utils.dart';
import '../../../data/models/enhanced_ticket_model.dart';
import '../../../data/models/enhanced_ticket_display_model.dart';
import '../../../core/services/data_resolution_service.dart';

class QrTicketScreen extends StatefulWidget {
  final EnhancedTicketModel ticket;
  final EnhancedTicketDisplayModel? enhancedDisplay;

  const QrTicketScreen({
    super.key,
    required this.ticket,
    this.enhancedDisplay,
  });

  @override
  State<QrTicketScreen> createState() => _QrTicketScreenState();
}

class _QrTicketScreenState extends State<QrTicketScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  EnhancedTicketDisplayModel? _resolvedDisplay;
  bool _isLoadingNames = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // If we don't have enhanced display data, try to resolve names
    if (widget.enhancedDisplay == null) {
      _resolveStationNames();
    } else {
      _resolvedDisplay = widget.enhancedDisplay;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  Future<void> _resolveStationNames() async {
    setState(() {
      _isLoadingNames = true;
    });

    try {
      final resolvedData = await DataResolutionService.resolveTicketData(
        boardingStationId: widget.ticket.boardingStationId,
        destinationStationId: widget.ticket.destinationStationId,
        busId: widget.ticket.busId,
        routeId: widget.ticket.routeId,
      );

      setState(() {
        _resolvedDisplay = EnhancedTicketDisplayModel.withResolvedNames(
          ticket: widget.ticket.toTicketModel(),
          boardingStationName: resolvedData['boardingStation']!,
          destinationStationName: resolvedData['destinationStation']!,
          busNumber: resolvedData['busNumber']!,
          routeName: resolvedData['routeName']!,
        );
        _isLoadingNames = false;
      });
    } catch (e) {
      setState(() {
        _resolvedDisplay = EnhancedTicketDisplayModel.fromTicket(
            widget.ticket.toTicketModel());
        _isLoadingNames = false;
      });
    }
  }

  Color _getStatusColor() {
    if (widget.ticket.isExpired) {
      return AppTheme.errorColor;
    } else if (widget.ticket.isUsed) {
      return Colors.orange;
    } else if (widget.ticket.isActive) {
      return AppTheme.successColor;
    }
    return AppTheme.textSecondary;
  }

  String _getStatusText() {
    if (widget.ticket.isExpired) {
      return 'EXPIRED';
    } else if (widget.ticket.isUsed) {
      return 'USED';
    } else if (widget.ticket.isActive) {
      return 'ACTIVE';
    }
    return widget.ticket.status.toUpperCase();
  }

  void _copyTicketNumber() {
    Clipboard.setData(ClipboardData(text: widget.ticket.ticketNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket number copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Your Ticket'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Main Ticket Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getStatusText(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Ticket Number
                                GestureDetector(
                                  onTap: _copyTicketNumber,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.ticket.ticketNumber,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.copy,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Journey Info with resolved names
                                _buildJourneyInfo(),
                              ],
                            ),
                          ),

                          // QR Code Section
                          Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Show this QR code to the conductor',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 16),

                                // QR Code
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: QrUtils.generateQrWidget(
                                    widget.ticket.qrData,
                                    size: 200,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Validation Code
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Validation: ${widget.ticket.qrData.validationCode}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ticket Details Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ticket Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _buildDetailRow('Bus Number', _getBusDisplay()),
                            _buildDetailRow('Route', _getRouteDisplay()),
                            _buildDetailRow('Ticket Type',
                                widget.ticket.ticketType.toUpperCase()),
                            _buildDetailRow('Travel Date',
                                _formatDate(widget.ticket.travelDate)),
                            _buildDetailRow('Valid Until',
                                _formatDateTime(widget.ticket.validUntil)),
                            _buildDetailRow('Booking Time',
                                _formatDateTime(widget.ticket.bookingTime)),

                            const Divider(height: 24),

                            // Fare Details
                            const Text(
                              'Fare Breakdown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildDetailRow('Base Fare',
                                '₹${widget.ticket.fareDetails.baseFare.toStringAsFixed(2)}'),
                            if (widget.ticket.fareDetails.totalSubsidyAmount >
                                0)
                              _buildDetailRow('Subsidy',
                                  '-₹${widget.ticket.fareDetails.totalSubsidyAmount.toStringAsFixed(2)}',
                                  color: AppTheme.successColor),
                            if (widget.ticket.fareDetails.totalTaxAmount > 0)
                              _buildDetailRow('Tax',
                                  '₹${widget.ticket.fareDetails.totalTaxAmount.toStringAsFixed(2)}'),

                            const Divider(height: 16),

                            _buildDetailRow(
                              'Final Amount',
                              '₹${widget.ticket.fareDetails.finalAmount.toStringAsFixed(2)}',
                              isTotal: true,
                            ),

                            const Divider(height: 24),

                            // Payment Details
                            const Text(
                              'Payment Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildDetailRow(
                                'Payment Mode',
                                widget.ticket.paymentDetails.paymentMode
                                    .toUpperCase()),
                            _buildDetailRow('Transaction ID',
                                widget.ticket.paymentDetails.transactionId),
                            _buildDetailRow(
                                'Payment Status',
                                widget.ticket.paymentDetails.paymentStatus
                                    .toUpperCase(),
                                color: widget.ticket.paymentDetails
                                            .paymentStatus ==
                                        'completed'
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor),
                            _buildDetailRow(
                                'Payment Time',
                                _formatDateTime(
                                    widget.ticket.paymentDetails.paymentTime)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Important Notes Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Important Notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Show this QR code to the bus conductor for verification\n'
                            '• Keep your phone charged and ready\n'
                            '• This ticket is valid only for the specified date and route\n'
                            '• Screenshot of this ticket is also valid\n'
                            '• Contact support if you face any issues',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Home'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/my-tickets');
                },
                icon: const Icon(Icons.confirmation_number),
                label: const Text('My Tickets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ??
                  (isTotal ? AppTheme.primaryColor : AppTheme.textPrimary),
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyInfo() {
    final displayTicket = _resolvedDisplay;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'FROM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isLoadingNames) ...[
                    const SizedBox(width: 4),
                    const SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                displayTicket?.boardingStationName ??
                    'Station ${widget.ticket.boardingStationId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayTicket?.destinationStationName ??
                    'Station ${widget.ticket.destinationStationId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBusDisplay() {
    final displayTicket = _resolvedDisplay;
    if (displayTicket?.isDataResolved == true) {
      return displayTicket!.busNumber;
    }
    return widget.ticket.busId;
  }

  String _getRouteDisplay() {
    final displayTicket = _resolvedDisplay;
    if (displayTicket?.isDataResolved == true &&
        displayTicket!.routeName.isNotEmpty &&
        !displayTicket.routeName.startsWith('Route')) {
      return displayTicket.routeName;
    }
    return widget.ticket.routeId;
  }
}
