class ApiConfig {
  // Backend configuration
  static const String _localhost = 'http://localhost:5000';
  static const String _androidEmulator = 'http://10.0.2.2:5000';
  static const String _iosSimulator = 'http://127.0.0.1:5000';
  
  // You can set your computer's IP address here for physical device testing
  // Find your IP with: ipconfig (Windows) or ifconfig (Mac/Linux)
  static const String _physicalDevice = 'http://192.168.1.100:5000'; // Replace with your IP
  
  // Current configuration - change this based on your testing environment
  static const String baseUrl = _localhost; // Change this as needed
  
  // Timeout settings
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration healthCheckTimeout = Duration(seconds: 5);
  
  // API endpoints
  static const String summarizeEndpoint = '/summarize';
  static const String paraphraseEndpoint = '/paraphrase';
  static const String healthEndpoint = '/health';
  
  // Helper method to get the appropriate URL based on platform
  static String getBaseUrl() {
    // You can add platform detection logic here if needed
    return baseUrl;
  }
}