# Saral Yatri - QR Based Bus Booking App

A comprehensive Flutter application for QR-based bus booking system designed for government bus services. This app provides digital after-boarding ticketing solution with automatic subsidy application.

## Features

### Core Functionality
- **QR Code Scanning**: Scan bus QR codes or conductor QR codes for ticket booking
- **Manual Bus Entry**: Enter bus number manually for booking
- **Real-time Map**: Interactive map showing bus locations and bus stops
- **Digital Ticketing**: Generate QR-based digital tickets
- **Automatic Subsidies**: Apply eligible government subsidies automatically
- **Ticket Management**: View active and expired tickets
- **Offline Capability**: Basic functionality works offline

### User Experience
- **Clean Architecture**: Well-structured codebase with separation of concerns
- **State Management**: Riverpod for efficient state management
- **Responsive UI**: Material Design 3 with custom theming
- **Screen Protection**: Prevents screenshots of tickets
- **Location Services**: GPS-based bus and stop discovery

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 3.0.3
- **HTTP Client**: Dio 5.9.0
- **Maps**: Flutter Map
- **QR Code**: QR 3.0.2, Mobile Scanner 7.1.2
- **Location**: Geolocator
- **UI Components**: Animated Custom Dropdown 3.1.1
- **Permissions**: Permission Handler
- **Security**: Screen Protector
- **Connectivity**: Connectivity Plus
- **Logging**: Dev Log

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── network/
│   │   └── api_client.dart
│   ├── services/
│   │   ├── location_service.dart
│   │   ├── permission_service.dart
│   │   └── storage_service.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   ├── bus_model.dart
│   │   ├── bus_stop_model.dart
│   │   ├── ticket_model.dart
│   │   └── user_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── bus_repository.dart
│       └── ticket_repository.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── bus_provider.dart
│   │   └── ticket_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── booking/
│   │   │   └── booking_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── qr_scanner/
│   │   │   └── qr_scanner_screen.dart
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   └── ticket/
│   │       └── ticket_screen.dart
│   └── widgets/
│       ├── booking_options_drawer.dart
│       ├── bus_marker.dart
│       ├── bus_stop_marker.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── fare_breakdown_card.dart
│       └── qr_code_widget.dart
├── app.dart
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Piyu-Pika/saral_yatri_user
   cd saral_yatri_user
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add fonts** (Optional)
   - Download Poppins font from Google Fonts
   - Place font files in `assets/fonts/` directory

4. **Configure API endpoints**
   - Update `lib/core/constants/app_constants.dart` with your backend URL

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### API Configuration
Update the base URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com';
```

### Permissions
The app requires the following permissions:
- Camera (for QR scanning)
- Location (for GPS and nearby buses)
- Internet (for API calls)
- Network State (for connectivity checks)

## Key Features Implementation

### 1. QR Code Scanning
- Uses `mobile_scanner` for camera-based QR scanning
- Supports both bus QR codes and conductor QR codes
- Real-time processing with visual feedback

### 2. Map Integration
- Interactive map using `flutter_map`
- Real-time bus locations
- Bus stop markers
- User location tracking

### 3. Ticket Management
- Digital ticket generation with QR codes
- Automatic expiry handling
- Visual indicators for ticket status
- Screen protection to prevent screenshots

### 4. State Management
- Riverpod providers for clean state management
- Separate providers for auth, bus, and ticket states
- Reactive UI updates

### 5. Offline Support
- Local storage using SharedPreferences
- Cached data for offline viewing
- Connectivity status monitoring

## Workflow

1. **User Authentication**: Login with email/password
2. **Home Screen**: Interactive map with buses and stops
3. **Booking Options**: 
   - Scan bus QR code
   - Scan conductor QR code  
   - Enter bus number manually
4. **Route Selection**: Choose boarding and dropping stops
5. **Fare Calculation**: Automatic subsidy application
6. **Payment**: Digital payment processing
7. **Ticket Generation**: QR-based digital ticket
8. **Verification**: Conductor scans passenger ticket

## Security Features

- Screen protection prevents ticket screenshots
- Encrypted QR codes with expiry validation
- Secure API communication
- Token-based authentication

## License

This project is licensed under the MIT License.
