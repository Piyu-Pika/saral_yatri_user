import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/ticket_provider.dart' as presentation_provider;
import '../../widgets/ticket/enhanced_ticket_list_item.dart';
import 'ticket_detail_screen.dart';
import 'qr_ticket_screen.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try to load tickets with resolved names, but handle gracefully if API is not available
      try {
        ref
            .read(presentation_provider.ticketProvider.notifier)
            .loadUserTicketsWithResolvedNames();
      } catch (e) {
        // For demo purposes, add some mock tickets
        _addMockTickets();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addMockTickets() {
    // Mock tickets are now handled in the provider
    // This method is kept for future use if needed
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(presentation_provider.ticketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
          // Tab bar
          Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Expired'),
                Tab(text: 'All'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: (ticketState.isLoading || ticketState.isLoadingEnhanced)
                ? const Center(child: CircularProgressIndicator())
                : ticketState.error != null
                    ? Center(
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
                              'Failed to load tickets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticketState.error!,
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
                                    .read(presentation_provider
                                        .ticketProvider.notifier)
                                    .refreshUserTicketsWithResolvedNames();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Active tickets
                          _buildEnhancedTicketList(
                            ticketState.enhancedTickets
                                .where((t) => t.ticket.isActive)
                                .toList(),
                            'No active tickets',
                            'Book a ticket to see it here',
                          ),

                          // Expired tickets
                          _buildEnhancedTicketList(
                            ticketState.enhancedTickets
                                .where((t) => t.ticket.isExpired)
                                .toList(),
                            'No expired tickets',
                            'Expired tickets will appear here',
                          ),

                          // All tickets
                          _buildEnhancedTicketList(
                            ticketState.enhancedTickets,
                            'No tickets found',
                            'Your booking history will appear here',
                          ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/booking');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Book Ticket'),
      ),
    );
  }



  Widget _buildEnhancedTicketList(
      List enhancedTickets, String emptyTitle, String emptySubtitle) {
    if (enhancedTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
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

              if (currentEnhancedTicket != null && currentEnhancedTicket.id == ticket.id) {
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
}
