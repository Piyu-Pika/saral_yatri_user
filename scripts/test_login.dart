#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Quick login test with user/user123 credentials
void main() async {
  print('🔐 Testing Login Credentials');
  print('============================');
  
  final tester = LoginTester();
  await tester.testLogin();
}

class LoginTester {
  static const String baseUrl = 'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1';
  late Dio dio;
  
  LoginTester() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // Add logging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  Future<void> testLogin() async {
    try {
      print('📱 Testing login with credentials:');
      print('   Username: user');
      print('   Password: user123');
      print('');
      
      final loginData = {
        'username': 'user',
        'password': 'user123',
      };
      
      print('🔄 Sending login request...');
      final response = await dio.post('/auth/login', data: loginData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['data']?['token'] != null) {
          print('✅ Login Successful!');
          print('   Token: ${data['data']['token'].toString().substring(0, 20)}...');
          
          if (data['data']['user'] != null) {
            print('   User ID: ${data['data']['user']['id']}');
            print('   Username: ${data['data']['user']['username']}');
            print('   Role: ${data['data']['user']['role']}');
          }
          
          // Test authenticated endpoint
          await testAuthenticatedEndpoint(data['data']['token']);
          
        } else {
          print('❌ Login failed: No token in response');
          print('   Response: $data');
        }
      } else {
        print('❌ Login failed: HTTP ${response.statusCode}');
        print('   Response: ${response.data}');
      }
      
    } catch (e) {
      print('❌ Login error: $e');
      
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
      }
    }
  }

  Future<void> testAuthenticatedEndpoint(String token) async {
    try {
      print('\n🔒 Testing authenticated endpoint...');
      
      dio.options.headers['Authorization'] = 'Bearer $token';
      
      final response = await dio.get('/auth/profile');
      
      if (response.statusCode == 200) {
        print('✅ Profile endpoint working');
        final profile = response.data['data'];
        print('   Profile: ${profile['username']} (${profile['role']})');
      } else {
        print('❌ Profile endpoint failed: HTTP ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Profile endpoint error: $e');
    }
  }
}