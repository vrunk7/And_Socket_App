import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: const Color(0xFF00FFC6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFC6), // Cyberpunk Green
          secondary: Color(0xFFBB86FC),
        ),
      ),
      home: const SysAdminConsole(),
    );
  }
}

class SysAdminConsole extends StatefulWidget {
  const SysAdminConsole({super.key});

  @override
  State<SysAdminConsole> createState() => _SysAdminConsoleState();
}

class _SysAdminConsoleState extends State<SysAdminConsole> {
  final TextEditingController _controller = TextEditingController();
  String _status = "Ready to Connect";
  String _serverStats = "Server Status: Unknown";
  String _selectedSeverity = "INFO";

  // REPLACE WITH YOUR IP
  final String serverIP = '192.168.0.103';
  final int serverPort = 12345;

  // DYNAMIC GREETING LOGIC
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Admin';
    if (hour < 17) return 'Good Afternoon, Admin';
    return 'Good Evening, Admin';
  }

  Color getSeverityColor() {
    switch (_selectedSeverity) {
      case "CRITICAL":
        return Colors.redAccent;
      case "WARNING":
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Future<void> _sendLog() async {
    if (_controller.text.isEmpty) return;
    _communicate("$_selectedSeverity|${_controller.text}");
    _controller.clear();
  }

  Future<void> _getStats() async {
    _communicate("GET_STATS");
  }

  Future<void> _communicate(String message) async {
    try {
      Socket socket = await Socket.connect(serverIP, serverPort);
      socket.write(message);

      socket.listen((List<int> event) {
        String response = String.fromCharCodes(event);
        setState(() {
          if (message == "GET_STATS") {
            _serverStats = response;
          } else {
            _status = "Server: $response";
          }
        });
        socket.destroy();
      });
    } catch (e) {
      setState(() {
        _status = "Connection Error: Is Server Running?";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NOC COMMAND CENTER",
          style: TextStyle(letterSpacing: 2, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 10,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getGreeting(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "System Operational",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.greenAccent, letterSpacing: 1.5),
              ),

              const SizedBox(height: 30),

              // SERVER HEALTH DASHBOARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.dns, color: Colors.greenAccent, size: 50),
                    const SizedBox(height: 15),
                    Text(
                      _serverStats,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: _getStats,
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Colors.greenAccent,
                      ),
                      label: const Text(
                        "CHECK SERVER HEALTH",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),
              const Text(
                "LOG NEW INCIDENT",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // SEVERITY SELECTOR
              Card(
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSeverity,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2C2C2C),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: getSeverityColor(),
                      ),
                      items: ["INFO", "WARNING", "CRITICAL"].map((String val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text(
                            val,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSeverity = val!),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // INPUT FIELD
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  hintText: 'Describe system anomaly...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.terminal, color: getSeverityColor()),
                ),
              ),

              const SizedBox(height: 30),

              // SEND BUTTON
              ElevatedButton(
                onPressed: _sendLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: getSeverityColor(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "TRANSMIT LOG",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  _status,
                  style: TextStyle(color: getSeverityColor(), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
