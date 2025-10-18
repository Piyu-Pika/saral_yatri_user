import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/ticket_provider.dart';
import '../../widgets/ticket/ticket_list_item.dart';
import 'ticket_detail_screen.dart';

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
      ref.read(ticketProvider.notifier).loadMyTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);

    return Scaffold(
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
            child: ticketState.isLoading
                ? const Center(
                    child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Active tickets
                      _buildTicketList(
                        ticketState.tickets.where((t) => t.isActive).toList(),
                        'No active tickets',
                        'Book a ticket to see it here',
                      ),

                      // Expired tickets
                      _buildTicketList(
                        ticketState.tickets.where((t) => t.isExpired).toList(),
                        'No expired tickets',
                        'Expired tickets will appear here',
                      ),

                      // All tickets
                      _buildTicketList(
                        ticketState.tickets,
                        'No tickets found',
                        'Your booking history will appear here',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(
      List tickets, String emptyTitle, String emptySubtitle) {
    if (tickets.isEmpty) {
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
        await ref.read(ticketProvider.notifier).loadMyTickets();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return TicketListItemWidget(
            ticket: ticket,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TicketDetailScreen(ticket: ticket),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
