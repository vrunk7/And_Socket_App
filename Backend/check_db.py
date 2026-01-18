import sqlite3

# Connect to the database
conn = sqlite3.connect('sysadmin_logs.db')
cursor = conn.cursor()

# Select all data
cursor.execute("SELECT * FROM logs")
rows = cursor.fetchall()

print("\n--- DATABASE CONTENTS ---")
for row in rows:
    print(f"ID: {row[0]} | Time: {row[1]} | IP: {row[2]} | Severity: {row[3]} | Msg: {row[4]}")
print("-------------------------\n")

conn.close()