import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/api_diagnostic_helper.dart';
import '../../../core/utils/comprehensive_api_test.dart';
import '../../../core/utils/ticket_booking_diagnostic.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class ApiDiagnosticScreen extends ConsumerStatefulWidget {
  const ApiDiagnosticScreen({super.key});

  @override
  ConsumerState<ApiDiagnosticScreen> createState() => _ApiDiagnosticScreenState();
}

class _ApiDiagnosticScreenState extends ConsumerState<ApiDiagnosticScreen> {
  bool _isRunning = false;
  Map<String, dynamic>? _results;
  late ApiDiagnosticHelper _diagnosticHelper;
  late ComprehensiveApiTest _comprehensiveTest;
  late TicketBookingDiagnostic _ticketDiagnostic;

  @override
  void initState() {
    super.initState();
    final apiService = ref.read(apiServiceProvider);
    _diagnosticHelper = ApiDiagnosticHelper(apiService);
    _comprehensiveTest = ComprehensiveApiTest(apiService);
    _ticketDiagnostic = TicketBookingDiagnostic(apiService);
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results = null;
    });

    try {
      final results = await _diagnosticHelper.runDiagnostics();
      setState(() {
        _results = results;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results = {'error': e.toString()};
        _isRunning = false;
      });
    }
  }

  Future<void> _runComprehensiveTest() async {
    setState(() {
      _isRunning = true;
      _results = null;
    });

    try {
      final results = await _comprehensiveTest.runComprehensiveTest();
      setState(() {
        _results = results;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results = {'error': e.toString()};
        _isRunning = false;
      });
    }
  }

  Future<void> _runTicketDiagnostic() async {
    setState(() {
      _isRunning = true;
      _results = null;
    });

    try {
      final results = await _ticketDiagnostic.diagnoseTicketBooking();
      setState(() {
        _results = results;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results = {'error': e.toString()};
        _isRunning = false;
      });
    }
  }

  Future<void> _attemptQuickFixes() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final fixes = await _diagnosticHelper.attemptQuickFixes();
      
      // Show fixes result
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quick Fixes Applied'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fixes.entries.map((entry) {
                final success = entry.value['success'] == true;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        success ? Icons.check_circle : Icons.error,
                        color: success ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: success ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      // Re-run diagnostics after fixes
      await _runDiagnostics();
      
    } catch (e) {
      setState(() {
        _isRunning = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quick fixes failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'API Diagnostics',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'API Diagnostic Tool',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This tool helps identify and fix issues with:\n'
                    '• Active stations not showing according to route\n'
                    '• Fare calculation problems\n'
                    '• Ticket booking and storage issues',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runDiagnostics,
                        icon: _isRunning 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isRunning ? 'Running...' : 'Basic Diagnostics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning || _results == null ? null : _attemptQuickFixes,
                        icon: const Icon(Icons.build),
                        label: const Text('Quick Fixes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runComprehensiveTest,
                        icon: _isRunning 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.verified),
                        label: Text(_isRunning ? 'Running...' : 'Comprehensive Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runTicketDiagnostic,
                        icon: _isRunning 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.bug_report),
                        label: Text(_isRunning ? 'Running...' : 'Ticket Diagnostic'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Results
            if (_results != null) ...[
              const Text(
                'Diagnostic Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildResultsView(),
              ),
            ] else if (!_isRunning) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Run diagnostics to identify API issues',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_results == null) return const SizedBox();
    
    if (_results!['error'] != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Diagnostic Error',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _results!['error'].toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          if (_results!['summary'] != null) _buildSummaryCard(),
          
          const SizedBox(height: 16),
          
          // Detailed results
          ..._buildDetailedResults(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _results!['summary'] as Map<String, dynamic>;
    final totalTests = summary['totalTests'] ?? 0;
    final passedTests = summary['passedTests'] ?? 0;
    final issues = summary['issues'] as List? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: issues.isEmpty ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: issues.isEmpty ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                issues.isEmpty ? Icons.check_circle : Icons.warning,
                color: issues.isEmpty ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: issues.isEmpty ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Tests: $passedTests/$totalTests passed'),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Issues Found:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ...issues.map((issue) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('• $issue'),
            )),
          ],
          if (summary['recommendations'] != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Recommendations:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ...(summary['recommendations'] as List).map((rec) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('• $rec'),
            )),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDetailedResults() {
    final widgets = <Widget>[];
    
    final categories = ['stations', 'routes', 'buses', 'fareCalculation', 'tickets'];
    final categoryNames = {
      'stations': 'Station APIs',
      'routes': 'Route APIs',
      'buses': 'Bus APIs', 
      'fareCalculation': 'Fare Calculation',
      'tickets': 'Ticket Operations',
    };
    
    for (final category in categories) {
      if (_results![category] != null) {
        widgets.add(_buildCategoryCard(
          categoryNames[category]!,
          _results![category] as Map<String, dynamic>,
        ));
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    return widgets;
  }

  Widget _buildCategoryCard(String title, Map<String, dynamic> data) {
    final hasError = data['error'] != null;
    final tests = data.entries.where((e) => e.key != 'error').toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (hasError) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['error'].toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...tests.map((test) => _buildTestResult(test.key, test.value)),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResult(String testName, dynamic testData) {
    if (testData is! Map<String, dynamic>) return const SizedBox();
    
    final success = testData['success'] == true;
    final icon = success ? Icons.check_circle : Icons.error;
    final color = success ? Colors.green : Colors.red;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                if (testData['error'] != null)
                  Text(
                    testData['error'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                if (testData['count'] != null)
                  Text(
                    'Count: ${testData['count']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}