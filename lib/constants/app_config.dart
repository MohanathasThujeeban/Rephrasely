class ApiConfig {
  // Backend Configuration
  // Change these values based on your deployment setup
  
  // For local development
  static const String localUrl = 'http://localhost:5000';
  
  // For Android emulator (when backend runs on host machine)
  static const String androidEmulatorUrl = 'http://10.0.2.2:5000';
  
  // For iOS simulator (when backend runs on host machine)
  static const String iosSimulatorUrl = 'http://127.0.0.1:5000';
  
  // For physical device on same network (your computer's IP)
  static const String networkUrl = 'http://10.11.8.134:5000';
  
  // Production URL (when deployed to cloud)
  static const String productionUrl = 'https://your-backend-domain.com';
  
  // Current environment - set to network for physical device testing
  static const AppEnvironment environment = AppEnvironment.network;
  
  // Get the appropriate base URL for current environment
  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.local:
        return localUrl;
      case AppEnvironment.androidEmulator:
        return androidEmulatorUrl;
      case AppEnvironment.iosSimulator:
        return iosSimulatorUrl;
      case AppEnvironment.network:
        return networkUrl;
      case AppEnvironment.production:
        return productionUrl;
    }
  }
}

enum AppEnvironment {
  local,
  androidEmulator,
  iosSimulator,
  network,
  production,
}