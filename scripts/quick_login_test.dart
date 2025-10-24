#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Quick test to verify login response parsing
void main() async {
  print('🔐 Quick Login Test');
  print('==================');

  final dio = Dio(BaseOptions(
    baseUrl: 'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  try {
    final loginData = {
      'username': 'user',
      'password': 'user123',
    };

    print('📤 Sending login request...');
    final response = await dio.post('/auth/login', data: loginData);

    print('📥 Response received:');
    print('   Status: ${response.statusCode}');
    print('   Data structure: ${response.data.keys.toList()}');

    if (response.data['data'] != null) {
      final data = response.data['data'];
      print('   Data keys: ${data.keys.toList()}');

      if (data['token'] != null) {
        print('✅ Token found: ${data['token'].toString().substring(0, 30)}...');

        if (data['user'] != null) {
          print(
              '✅ User found: ${data['user']['username']} (${data['user']['role']})');
        }

        // Test authenticated request
        dio.options.headers['Authorization'] = 'Bearer ${data['token']}';

        print('\n🔒 Testing authenticated endpoint...');
        final profileResponse = await dio.get('/auth/profile');

        if (profileResponse.statusCode == 200) {
          print('✅ Profile endpoint working');
          final profile = profileResponse.data['data'];
          print('   Profile: ${profile['username']} (${profile['role']})');
        }
      } else {
        print('❌ No token in data');
      }
    } else {
      print('❌ No data field in response');
    }
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('   Response: ${e.response?.data}');
    }
  }
}
