#!/usr/bin/env dart

import 'dart:io';
import 'api_diagnostic_script.dart';

/// Command line script to run API diagnostics
/// Usage: dart scripts/run_diagnostics.dart
void main(List<String> args) async {
  print('🚀 Saral Yatri API Diagnostic Tool');
  print('=' * 50);
  
  // Check if we should run in interactive mode
  bool interactive = args.contains('--interactive') || args.contains('-i');
  
  if (interactive) {
    await runInteractiveMode();
  } else {
    await runAutomaticMode();
  }
}

Future<void> runAutomaticMode() async {
  print('Running automatic diagnostics...\n');
  
  final diagnostic = ApiDiagnosticScript();
  await diagnostic.runDiagnostics();
  diagnostic.generateReport();
}

Future<void> runInteractiveMode() async {
  final diagnostic = ApiDiagnosticScript();
  
  while (true) {
    print('\n📋 Choose an option:');
    print('1. Run full diagnostics');
    print('2. Test specific endpoint');
    print('3. Generate report');
    print('4. Exit');
    print('\nEnter your choice (1-4): ');
    
    final input = stdin.readLineSync();
    
    switch (input) {
      case '1':
        print('\n🔍 Running full diagnostics...');
        await diagnostic.runDiagnostics();
        break;
        
      case '2':
        await testSpecificEndpoint(diagnostic);
        break;
        
      case '3':
        diagnostic.generateReport();
        break;
        
      case '4':
        print('👋 Goodbye!');
        exit(0);
        
      default:
        print('❌ Invalid choice. Please enter 1-4.');
    }
  }
}

Future<void> testSpecificEndpoint(ApiDiagnosticScript diagnostic) async {
  print('\n🎯 Available endpoints to test:');
  print('1. Authentication');
  print('2. Stations');
  print('3. Routes');
  print('4. Buses');
  print('5. Fare Calculation');
  print('6. Tickets');
  print('\nEnter endpoint number (1-6): ');
  
  final input = stdin.readLineSync();
  
  switch (input) {
    case '1':
      print('🔐 Testing authentication...');
      // Add specific auth test
      break;
    case '2':
      print('🚏 Testing stations...');
      // Add specific station test
      break;
    case '3':
      print('🛣️ Testing routes...');
      // Add specific route test
      break;
    case '4':
      print('🚌 Testing buses...');
      // Add specific bus test
      break;
    case '5':
      print('💰 Testing fare calculation...');
      // Add specific fare test
      break;
    case '6':
      print('🎫 Testing tickets...');
      // Add specific ticket test
      break;
    default:
      print('❌ Invalid choice.');
  }
}