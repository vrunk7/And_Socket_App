import socket
import sqlite3
import threading
import datetime

def init_db():
    conn = sqlite3.connect('sysadmin_logs.db', check_same_thread=False)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            client_ip TEXT,
            severity TEXT,
            message TEXT
        )
    ''')
    conn.commit()
    conn.close()

def handle_client(client_socket, addr):
    print(f"[+] Connection from {addr}")
    try:
        data = client_socket.recv(1024).decode('utf-8')
        
        if data == "GET_STATS":
            conn = sqlite3.connect('sysadmin_logs.db', check_same_thread=False)
            cursor = conn.cursor()
            # Count total logs
            cursor.execute("SELECT COUNT(*) FROM logs")
            count = cursor.fetchone()[0]
            # Get last log time
            cursor.execute("SELECT timestamp FROM logs ORDER BY id DESC LIMIT 1")
            last_log = cursor.fetchone()
            last_time = last_log[0] if last_log else "Never"
            conn.close()
            
            response = f"Logs Stored: {count} | Last Activity: {last_time}"
            client_socket.send(response.encode('utf-8'))
            print(f"[STATUS QUERY] Sent stats to {addr[0]}")
            
        elif "|" in data:
            severity, message = data.split("|", 1)
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{severity}] {message}")

            conn = sqlite3.connect('sysadmin_logs.db', check_same_thread=False)
            cursor = conn.cursor()
            cursor.execute("INSERT INTO logs (timestamp, client_ip, severity, message) VALUES (?, ?, ?, ?)", 
                           (timestamp, addr[0], severity, message))
            conn.commit()
            conn.close()
            client_socket.send("Log Secured on Server".encode('utf-8'))
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        client_socket.close()

def start_server():
    init_db()
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('0.0.0.0', 12345))
    server.listen(5)
    print("[*] SysAdmin Server Online (Ready for Logs & Stats)...")

    while True:
        client, addr = server.accept()
        threading.Thread(target=handle_client, args=(client, addr)).start()

if __name__ == "__main__":
    start_server()
