import 'package:dev_log/dev_log.dart';
import '../services/data_resolution_service.dart';
import '../../data/repositories/ticket_repository.dart';

class TicketDataTest {
  /// Test the complete ticket data resolution flow
  static Future<void> testTicketDataResolution() async {
    try {
      Log.i('🧪 Testing ticket data resolution...');
      
      final repository = TicketRepository();
      
      // Test 1: Get raw tickets
      Log.i('📋 Test 1: Fetching raw tickets...');
      final rawTickets = await repository.getUserTickets();
      Log.i('✅ Found ${rawTickets.length} raw tickets');
      
      if (rawTickets.isNotEmpty) {
        final firstTicket = rawTickets.first;
        Log.i('📝 First ticket: ${firstTicket.id}');
        Log.i('   Bus ID: ${firstTicket.busId}');
        Log.i('   Route ID: ${firstTicket.routeId}');
        Log.i('   Boarding Station ID: ${firstTicket.boardingStationId}');
        Log.i('   Destination Station ID: ${firstTicket.destinationStationId}');
      }
      
      // Test 2: Get enhanced tickets with resolved names
      Log.i('🔍 Test 2: Fetching enhanced tickets with resolved names...');
      final enhancedTickets = await repository.getUserTicketsWithResolvedNames();
      Log.i('✅ Found ${enhancedTickets.length} enhanced tickets');
      
      if (enhancedTickets.isNotEmpty) {
        final firstEnhanced = enhancedTickets.first;
        Log.i('📝 First enhanced ticket:');
        Log.i('   Ticket ID: ${firstEnhanced.ticket.id}');
        Log.i('   Bus Number: ${firstEnhanced.busNumber}');
        Log.i('   Route Name: ${firstEnhanced.routeName}');
        Log.i('   Boarding Station: ${firstEnhanced.boardingStationName}');
        Log.i('   Destination Station: ${firstEnhanced.destinationStationName}');
        Log.i('   Data Resolved: ${firstEnhanced.isDataResolved}');
        Log.i('   Route Display: ${firstEnhanced.routeDisplay}');
      }
      
      // Test 3: Test individual data resolution
      Log.i('🔧 Test 3: Testing individual data resolution...');
      
      if (rawTickets.isNotEmpty) {
        final testTicket = rawTickets.first;
        
        final resolvedData = await DataResolutionService.resolveTicketData(
          boardingStationId: testTicket.boardingStationId ?? '',
          destinationStationId: testTicket.destinationStationId ?? '',
          busId: testTicket.busId,
          routeId: testTicket.routeId,
        );
        
        Log.i('✅ Individual resolution results:');
        Log.i('   Boarding Station: ${resolvedData['boardingStation']}');
        Log.i('   Destination Station: ${resolvedData['destinationStation']}');
        Log.i('   Bus Number: ${resolvedData['busNumber']}');
        Log.i('   Route Name: ${resolvedData['routeName']}');
      }
      
      // Test 4: Cache statistics
      final cacheStats = DataResolutionService.getCacheStats();
      Log.i('📊 Cache Statistics:');
      Log.i('   Stations cached: ${cacheStats['stations']}');
      Log.i('   Buses cached: ${cacheStats['buses']}');
      Log.i('   Routes cached: ${cacheStats['routes']}');
      
      Log.i('🎉 All tests completed successfully!');
      
    } catch (e) {
      Log.e('❌ Test failed: $e');
    }
  }
  
  /// Test API connectivity for data resolution endpoints
  static Future<void> testDataResolutionAPIs() async {
    try {
      Log.i('🌐 Testing data resolution API endpoints...');
      
      // Test with sample IDs (these might not exist, but we can test the API calls)
      const sampleStationId = '68ea0d6cbbb53ea5402bd1a8';
      const sampleBusId = '68ea0d6cbbb53ea5402bd1b4';
      const sampleRouteId = '68ea0d6cbbb53ea5402bd1b0';
      
      Log.i('🚉 Testing station API...');
      final stationName = await DataResolutionService.getStationName(sampleStationId);
      Log.i('   Station result: $stationName');
      
      Log.i('🚌 Testing bus API...');
      final busNumber = await DataResolutionService.getBusNumber(sampleBusId);
      Log.i('   Bus result: $busNumber');
      
      Log.i('🛣️ Testing route API...');
      final routeName = await DataResolutionService.getRouteName(sampleRouteId);
      Log.i('   Route result: $routeName');
      
      Log.i('✅ API tests completed!');
      
    } catch (e) {
      Log.e('❌ API test failed: $e');
    }
  }
}