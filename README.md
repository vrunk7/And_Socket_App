# 📡 NOC Command Center (SysAdmin Socket Tool)

![Status](https://img.shields.io/badge/Status-Operational-brightgreen) ![Tech](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20SQLite-blue)

## Project Overview
The **NOC (Network Operations Center) Command Center** is a full-duplex client-server system designed for System Administrators who are constantly on the move. 

In a real-world data center, servers don't wait for you to be at your desk to crash. This tool allows an admin to:
1.  **Transmit critical logs** from a mobile device directly to the central server using raw TCP sockets.
2.  **Monitor server health** remotely by querying the database for log counts and timestamps.
3.  **Operate in low-light environments** using a custom "Cyberpunk" dark-mode interface.

## Key Features
* **Real-Time Incident Reporting:** Instant transmission of logs with Severity Tags (INFO, WARNING, CRITICAL).
* **Bi-Directional Communication:** Client can "pull" health stats from the server (Row count & Last Activity).
* **Custom TCP Protocol:** Uses a lightweight pipe-delimited protocol (`SEVERITY|MESSAGE`) for low latency.
* **Persistent Storage:** All logs are automatically saved to a SQLite database on the backend.
* **Multi-Threaded Server:** Handles multiple concurrent admin connections without blocking.

## Tech Stack
* **Client (Mobile):** Flutter (Dart `dart:io` for TCP Sockets)
* **Backend (Server):** Python 3 (Socket, Threading)
* **Database:** SQLite3
* **Architecture:** Client-Server (Full Duplex)

---

## 📂 Project Structure
```text
Socket-SysAdmin-Tool/
├── Backend/
│   ├── server.py          # The Multi-threaded Python Server
│   ├── check_db.py        # Audit script to verify database records
│   └── sysadmin_logs.db   # (Created automatically upon running)
├── /
│   ├── lib/main.dart      # The Flutter Frontend & Socket Logic
│   └── pubspec.yaml       # Project dependencies
└── README.md
```
---
## Installation & Setup Guide

### Prerequisites
- Python 3.x installed on your PC
- Flutter SDK installed and set up
- An Android device connected via USB  
- **Important:** Both the PC and the Android phone must be connected to the **same Wi-Fi Network**
--
### Step 1: Clone the Repository
```bash
git clone https://github.com/vrunk7/Socket-SysAdmin-Tool.git
cd Socket-SysAdmin-Tool
```

> Important: Both the PC and the Android phone must be connected to the same Wi-Fi Network.
--
### Step 2: Configure the Backend (Server)
1. Open your command prompt/terminal.
2. Find your local IP Address:
   - Windows: Run ipconfig (Look for IPv4 Address, usually 192.168.x.x).
   - Mac/Linux: Run ifconfig.
3. Navigate to the backend folder and start the server:
```bash
cd Backend
python server.py
```
4.You should see the message: [*] SysAdmin Server Online...
--
### Step 3: Configure the Frontend (Client)
1. Open the file sysadmin_log_tool/lib/main.dart in VS Code.
2. Locate the serverIP variable (around line 40):
```dart
// CHANGE THIS to your PC's IP Address found in Step 2
final String serverIP = '192.168.0.103';
```
3. Save the file.
--
### Step 4: Run the Application
1. Connect your Android phone via USB.
2. In your terminal, navigate to the mobile app folder:
```bash
cd ../sysadmin_log_tool
```
3. Run the app in release mode for best performance:
```bash
flutter run --release
```

---
## 🎮 How to Use (Demo Flow)
1. **Check Connection**: Tap the **"CHECK SERVER HEALTH"** button. You should see the total log count from the server.
2. **Send a Log**:
 - Select a Severity Level (e.g., **WARNING**).
 - Type a message (e.g., "Database Latency High").
 - Tap **"TRANSMIT LOG"**.
3. **Verify on PC**: Look at your Python terminal; you will see the log appear instantly.
4. **Verify Persistence**: Run the audit script to see the saved data:
```bash
python Backend/check_db.py
```

