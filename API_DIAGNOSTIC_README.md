# API Diagnostic Tools

This document explains how to use the API diagnostic tools to identify and fix the following issues:

1. **Active stations not showing according to route**
2. **Unable to calculate ticket fare**
3. **Tickets not stored in database for showing in my-tickets**

## 🔧 Available Tools

### 1. Flutter App Diagnostic Screen
Access from the app: **Profile → API Diagnostics**

**Features:**
- Run comprehensive API tests
- View detailed results with pass/fail status
- Apply quick fixes automatically
- Real-time issue identification

### 2. Command Line Diagnostic Script
Run from terminal: `dart scripts/run_diagnostics.dart`

**Features:**
- Standalone API testing
- Detailed logging
- Interactive mode available
- Generate diagnostic reports

### 3. Flutter Integration Helper
Use in your Flutter code:
```dart
final diagnosticHelper = ApiDiagnosticHelper(apiService);
final results = await diagnosticHelper.runDiagnostics();
```

## 🚨 Common Issues & Solutions

### Issue 1: Active Stations Not Showing According to Route

**Symptoms:**
- Station dropdown shows all stations instead of route-specific ones
- Route selection doesn't filter stations properly

**Diagnostic Tests:**
- ✅ `/routes/active` - Lists all active routes
- ❌ `/routes/{id}/stations` - **This endpoint is likely failing**
- ✅ `/stations/active` - Lists all stations

**Root Cause:**
The route-stations endpoint (`/routes/{route_id}/stations`) is not working properly.

**Solutions:**
1. **Backend Fix:** Ensure the route-stations endpoint returns proper data
2. **Database Check:** Verify station-route relationships in database
3. **API Response:** Check if stations have correct `route_id` and `sequence` fields

**Expected API Response:**
```json
{
  "data": [
    {
      "id": "station_1",
      "name": "Station Name",
      "route_id": "route_123",
      "sequence": 1,
      "latitude": 28.6139,
      "longitude": 77.2090
    }
  ]
}
```

### Issue 2: Unable to Calculate Ticket Fare

**Symptoms:**
- Fare calculation fails during booking
- "Unable to calculate fare" error messages

**Diagnostic Tests:**
- ✅ `/stations/active` - Gets station data
- ❌ `/tickets/calculate-fare` - **This endpoint is likely failing**

**Root Cause:**
The fare calculation endpoint is not working properly.

**Solutions:**
1. **Backend Fix:** Ensure fare calculation logic is implemented
2. **Distance Data:** Verify station distance/coordinate data exists
3. **Fare Rules:** Check if fare calculation rules are configured

**Expected API Request:**
```json
{
  "from_station_id": "station_1",
  "to_station_id": "station_2",
  "passenger_type": "general",
  "journey_date": "2024-01-01T10:00:00Z"
}
```

**Expected API Response:**
```json
{
  "data": {
    "base_fare": 10.0,
    "final_fare": 12.0,
    "distance": 5.2,
    "fare_breakdown": {
      "base": 10.0,
      "tax": 2.0
    }
  }
}
```

### Issue 3: Tickets Not Stored in Database

**Symptoms:**
- Ticket booking appears successful but tickets don't appear in my-tickets
- Empty ticket history

**Diagnostic Tests:**
- ✅ `/tickets/passenger/book` - Booking endpoint works
- ❌ `/tickets/passenger/my-tickets` - **Returns empty or fails**
- ❌ `/tickets/passenger/{id}` - **Individual ticket retrieval fails**

**Root Cause:**
Ticket booking doesn't properly save to database or user-ticket association is broken.

**Solutions:**
1. **Database Transaction:** Ensure ticket booking saves to database
2. **User Association:** Verify tickets are linked to correct user
3. **Authentication:** Check if proper user token is used

**Expected Booking Flow:**
1. POST `/tickets/passenger/book` → Creates ticket
2. GET `/tickets/passenger/my-tickets` → Shows created ticket
3. GET `/tickets/passenger/{ticket_id}` → Shows ticket details

## 🏃‍♂️ Quick Start Guide

### Step 1: Run Diagnostics
```bash
# Option 1: Command line
dart scripts/run_diagnostics.dart

# Option 2: In Flutter app
# Go to Profile → API Diagnostics → Run Diagnostics
```

### Step 2: Identify Issues
Look for ❌ failed tests in the results:
- Route stations failing = Issue #1
- Fare calculation failing = Issue #2  
- Ticket retrieval failing = Issue #3

### Step 3: Apply Fixes
```bash
# Try quick fixes first
# In app: Click "Quick Fixes" button

# Or manually fix the failing endpoints
```

### Step 4: Verify Fixes
```bash
# Re-run diagnostics to confirm fixes
dart scripts/run_diagnostics.dart
```

## 📊 Understanding Diagnostic Results

### Success Indicators ✅
- **Green checkmarks** = API working correctly
- **High pass rate** = Most functionality working
- **No critical issues** = App should work normally

### Failure Indicators ❌
- **Red X marks** = API endpoints failing
- **Error messages** = Specific failure reasons
- **Low pass rate** = Multiple issues need fixing

### Warning Indicators ⚠️
- **Orange warnings** = Potential issues
- **Data mismatches** = Inconsistent API responses
- **Performance issues** = Slow response times

## 🔍 Advanced Debugging

### Enable Detailed Logging
```dart
// In your app
AppLogger.setLevel(LogLevel.debug);

// Run diagnostics with verbose output
final results = await diagnosticHelper.runDiagnostics();
```

### Test Individual Endpoints
```bash
# Interactive mode
dart scripts/run_diagnostics.dart --interactive

# Then select specific endpoint to test
```

### Check Network Connectivity
```bash
# Test base URL connectivity
curl https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1/stations/active

# Check authentication
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1/tickets/passenger/my-tickets
```

## 🛠️ Backend Fixes Needed

Based on diagnostic results, these backend endpoints likely need fixes:

1. **Route Stations Endpoint**
   ```
   GET /api/v1/routes/{route_id}/stations
   ```
   
2. **Fare Calculation Endpoint**
   ```
   POST /api/v1/tickets/calculate-fare
   ```
   
3. **Ticket Storage/Retrieval**
   ```
   POST /api/v1/tickets/passenger/book
   GET /api/v1/tickets/passenger/my-tickets
   ```

## 📞 Support

If diagnostic tools show persistent failures:

1. **Check API server status**
2. **Verify database connectivity** 
3. **Review server logs**
4. **Contact backend team with diagnostic results**

The diagnostic tools provide detailed error messages and API responses to help identify the exact issues that need fixing.