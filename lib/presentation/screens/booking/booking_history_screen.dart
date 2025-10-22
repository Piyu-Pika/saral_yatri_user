import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/ticket_provider.dart' as presentation_provider;
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/ticket/enhanced_ticket_list_item.dart';
import '../ticket/ticket_detail_screen.dart';
import '../ticket/qr_ticket_screen.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(presentation_provider.ticketProvider.notifier)
          .loadUserTicketsWithResolvedNames();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(presentation_provider.ticketProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Booking History',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(presentation_provider.ticketProvider.notifier)
                  .refreshUserTicketsWithResolvedNames();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Bookings',
                    '${ticketState.enhancedTickets.length}',
                    Icons.confirmation_number,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active Tickets',
                    '${ticketState.enhancedTickets.where((t) => t.ticket.isActive).length}',
                    Icons.check_circle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Spent',
                    '₹${_calculateTotalSpent(ticketState.enhancedTickets)}',
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(
                  child: SizedBox(
                    width: 80,
                    child: Center(child: Text('All')),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: 80,
                    child: Center(child: Text('Active')),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: 80,
                    child: Center(child: Text('Completed')),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: 80,
                    child: Center(child: Text('Expired')),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: (ticketState.isLoading || ticketState.isLoadingEnhanced)
                ? const Center(child: CircularProgressIndicator())
                : ticketState.error != null
                    ? _buildErrorState(ticketState.error!)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // All bookings
                          _buildBookingList(
                            ticketState.enhancedTickets,
                            'No bookings found',
                            'Your booking history will appear here',
                          ),

                          // Active bookings
                          _buildBookingList(
                            ticketState.enhancedTickets
                                .where((t) => t.ticket.isActive)
                                .toList(),
                            'No active bookings',
                            'Active tickets will appear here',
                          ),

                          // Completed bookings
                          _buildBookingList(
                            ticketState.enhancedTickets
                                .where((t) =>
                                    t.ticket.status == 'used' ||
                                    t.ticket.isVerified)
                                .toList(),
                            'No completed bookings',
                            'Completed journeys will appear here',
                          ),

                          // Expired bookings
                          _buildBookingList(
                            ticketState.enhancedTickets
                                .where((t) => t.ticket.isExpired)
                                .toList(),
                            'No expired bookings',
                            'Expired tickets will appear here',
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load booking history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(presentation_provider.ticketProvider.notifier)
                  .refreshUserTicketsWithResolvedNames();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(
      List enhancedTickets, String emptyTitle, String emptySubtitle) {
    if (enhancedTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(presentation_provider.ticketProvider.notifier)
            .refreshUserTicketsWithResolvedNames();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enhancedTickets.length,
        itemBuilder: (context, index) {
          final enhancedTicket = enhancedTickets[index];
          final ticket = enhancedTicket.ticket;

          return EnhancedTicketListItemWidget(
            enhancedTicket: enhancedTicket,
            onTap: () {
              // Check if this is an enhanced ticket with QR data
              final currentEnhancedTicket = ref
                  .read(presentation_provider.ticketProvider)
                  .currentEnhancedTicket;

              if (currentEnhancedTicket != null &&
                  currentEnhancedTicket.id == ticket.id) {
                // Navigate to QR ticket screen for enhanced tickets
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QrTicketScreen(
                      ticket: currentEnhancedTicket,
                      enhancedDisplay: enhancedTicket,
                    ),
                  ),
                );
              } else {
                // Navigate to regular ticket detail screen with enhanced data
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TicketDetailScreen(
                      ticket: ticket,
                      enhancedTicket: enhancedTicket,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  String _calculateTotalSpent(List enhancedTickets) {
    double total = 0;
    for (final enhancedTicket in enhancedTickets) {
      total += enhancedTicket.ticket.finalFare;
    }
    return total.toStringAsFixed(0);
  }
}
