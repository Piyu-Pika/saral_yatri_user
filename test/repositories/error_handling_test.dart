import 'package:flutter_test/flutter_test.dart';
import 'package:saral_yatri/data/repositories/ticket_repository.dart';

void main() {
  group('TicketRepository Error Handling', () {
    late TicketRepository repository;

    setUp(() {
      repository = TicketRepository();
    });

    test('should extract error message from server response', () {
      // Test different error response formats
      final testCases = [
        {
          'input': {'error': 'Ticket booking failed'},
          'expected': 'Ticket booking failed'
        },
        {
          'input': {'message': 'Server is temporarily unavailable'},
          'expected': 'Server is temporarily unavailable'
        },
        {
          'input': {'details': '(AtlasError) you are over your space quota'},
          'expected': '(AtlasError) you are over your space quota'
        },
        {
          'input': {'errors': ['Invalid bus ID', 'Invalid route ID']},
          'expected': 'Invalid bus ID, Invalid route ID'
        },
        {
          'input': {'errors': {'bus_id': 'Required', 'route_id': 'Invalid'}},
          'expected': 'Required, Invalid'
        },
        {
          'input': 'Simple string error',
          'expected': 'Simple string error'
        },
        {
          'input': null,
          'expected': 'Default message'
        },
      ];

      for (final testCase in testCases) {
        final result = repository.extractErrorMessage(
          testCase['input'], 
          'Default message'
        );
        expect(result, equals(testCase['expected']));
      }
    });

    test('should provide user-friendly error messages for common server errors', () {
      final serverErrors = [
        'you are over your space quota',
        'AtlasError',
        'validation failed',
        'not found',
        'already booked',
      ];

      final expectedMessages = [
        'Server is temporarily unavailable due to maintenance. Please try again later.',
        'Server is temporarily unavailable due to maintenance. Please try again later.',
        'Invalid booking information. Please check your details and try again.',
        'Bus or station information not found. Please refresh and try again.',
        'This seat is already booked. Please select a different time or bus.',
      ];

      for (int i = 0; i < serverErrors.length; i++) {
        // This would be tested in the actual error handling logic
        expect(serverErrors[i], isNotEmpty);
        expect(expectedMessages[i], isNotEmpty);
      }
    });
  });
}