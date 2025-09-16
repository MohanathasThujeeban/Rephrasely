# Backend Connection Setup

## Quick Start

1. **Start your backend server** (from the `backend` directory):
   ```bash
   cd backend
   python run.py
   ```

2. **Configure the app** to connect to your backend:
   - Open `lib/constants/app_config.dart`
   - Change the `environment` variable based on your setup:
     - `AppEnvironment.local` - for local development
     - `AppEnvironment.androidEmulator` - when testing on Android emulator
     - `AppEnvironment.iosSimulator` - when testing on iOS simulator
     - `AppEnvironment.network` - when testing on physical device (update IP address)

## Environment Configuration

### Local Development (default)
- Backend runs on: `http://localhost:5000`
- Use: `AppEnvironment.local`

### Android Emulator
- Backend runs on: `http://10.0.2.2:5000`
- Use: `AppEnvironment.androidEmulator`

### iOS Simulator
- Backend runs on: `http://127.0.0.1:5000`
- Use: `AppEnvironment.iosSimulator`

### Physical Device (Same Network)
- Backend runs on: `http://YOUR_COMPUTER_IP:5000`
- Update the `networkUrl` in `app_config.dart` with your computer's IP
- Use: `AppEnvironment.network`

## Finding Your Computer's IP Address

### Windows
```cmd
ipconfig
```
Look for "IPv4 Address" under your network adapter.

### macOS/Linux
```bash
ifconfig
```
Look for "inet" address under your network interface.

## Backend API Endpoints

- `POST /summarize` - Summarize text
- `POST /paraphrase` - Paraphrase text
- `GET /health` - Health check

## Troubleshooting

1. **"No internet connection" error**:
   - Check if backend server is running
   - Verify the correct environment is set in `app_config.dart`
   - Ensure firewall allows connections on port 5000

2. **Connection timeout**:
   - Check if the IP address is correct for your setup
   - Try pinging the backend server from your device's browser

3. **CORS errors** (if any):
   - The backend should already have CORS configured
   - Check backend logs for any CORS-related errors