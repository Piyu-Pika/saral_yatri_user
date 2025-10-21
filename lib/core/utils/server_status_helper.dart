class ServerStatusHelper {
  /// Check if an error message indicates server maintenance or unavailability
  static bool isServerMaintenanceError(String? errorMessage) {
    if (errorMessage == null) return false;
    
    final maintenanceKeywords = [
      'space quota',
      'AtlasError',
      'Server is temporarily unavailable',
      'maintenance',
      'service unavailable',
      'temporarily down',
    ];
    
    return maintenanceKeywords.any((keyword) => 
        errorMessage.toLowerCase().contains(keyword.toLowerCase()));
  }
  
  /// Get user-friendly message for server maintenance
  static String getMaintenanceMessage() {
    return 'The booking system is temporarily unavailable due to server maintenance. '
           'You can create an offline ticket that will be synced when the server is back online.';
  }
  
  /// Get retry suggestions for users
  static List<String> getRetrySuggestions() {
    return [
      'Wait a few minutes and try again',
      'Check your internet connection',
      'Create an offline ticket for now',
      'Contact support if the issue persists',
    ];
  }
  
  /// Check if error is related to validation (user can fix)
  static bool isValidationError(String? errorMessage) {
    if (errorMessage == null) return false;
    
    final validationKeywords = [
      'validation',
      'invalid',
      'required',
      'missing',
      'format',
    ];
    
    return validationKeywords.any((keyword) => 
        errorMessage.toLowerCase().contains(keyword.toLowerCase()));
  }
  
  /// Check if error is related to data not found (user should refresh)
  static bool isDataNotFoundError(String? errorMessage) {
    if (errorMessage == null) return false;
    
    final notFoundKeywords = [
      'not found',
      'does not exist',
      'unavailable',
      'expired',
    ];
    
    return notFoundKeywords.any((keyword) => 
        errorMessage.toLowerCase().contains(keyword.toLowerCase()));
  }
}