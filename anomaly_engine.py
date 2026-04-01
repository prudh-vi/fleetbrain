import json
import math
from kafka import KafkaConsumer
import requests
from db import get_connection, setup_db
setup_db()

# Expected route coordinates
EXPECTED_ROUTE = [
    (12.9698, 77.7500),
    (12.9690, 77.7450),
    (12.9680, 77.7400),
    (12.9670, 77.7350),
    (12.9660, 77.7300),
    (12.9650, 77.7250),
    (12.9640, 77.7200),
    (12.9630, 77.7150),
    (12.9620, 77.7100),
    (12.9610, 77.7050),
]

SPEED_LIMIT = 80          # km/h
DEVIATION_THRESHOLD = 300 # meters
SILENCE_THRESHOLD = 10    # seconds between pings

last_ping_time = {}

def haversine(lat1, lng1, lat2, lng2):
    """Calculate distance in meters between two GPS coordinates"""
    R = 6371000  # Earth radius in meters
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lng2 - lng1)
    a = math.sin(dphi/2)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

def min_distance_from_route(lat, lng):
    """Find closest point on expected route to current position"""
    return min(haversine(lat, lng, rlat, rlng) for rlat, rlng in EXPECTED_ROUTE)

def check_anomalies(ping):
    anomalies = []

    # 1. Route deviation
    distance_off_route = min_distance_from_route(ping['lat'], ping['lng'])
    if distance_off_route > DEVIATION_THRESHOLD:
        anomalies.append({
            "type": "ROUTE_DEVIATION",
            "detail": f"Driver is {distance_off_route:.0f}m off expected route",
            "severity": "HIGH"
        })

    # 2. Overspeeding
    if ping['speed'] > SPEED_LIMIT:
        anomalies.append({
            "type": "OVERSPEED",
            "detail": f"Driver doing {ping['speed']} km/h — limit is {SPEED_LIMIT} km/h",
            "severity": "HIGH"
        })

    # 3. Driver silence (no pings)
    import time
    now = time.time()
    driver_id = ping['driver_id']
    if driver_id in last_ping_time:
        gap = now - last_ping_time[driver_id]
        if gap > SILENCE_THRESHOLD:
            anomalies.append({
                "type": "DRIVER_SILENT",
                "detail": f"No ping for {gap:.1f} seconds",
                "severity": "CRITICAL"
            })
    last_ping_time[driver_id] = now

    return anomalies

# Consume from Kafka
consumer = KafkaConsumer(
    'gps-pings',
    bootstrap_servers='localhost:9092',
    value_deserializer=lambda v: json.loads(v.decode('utf-8')),
    auto_offset_reset='latest'  # only new pings
)

print("🧠 Anomaly Engine running...\n")

for message in consumer:
    ping = message.value
    print(f"📍 Ping received: ({ping['lat']}, {ping['lng']}) | {ping['speed']} km/h")

    anomalies = check_anomalies(ping)

    if anomalies:
        conn = get_connection()
        cur = conn.cursor()
        for a in anomalies:
            severity_icon = "🔴" if a['severity'] == "CRITICAL" else "⚠️"
            print(f"  {severity_icon} ANOMALY [{a['type']}] — {a['detail']}")

            # Save to DB
            conn = get_connection()
            cur.execute("""
        INSERT INTO gps_pings (trip_id, driver_id, lat, lng, speed)
        VALUES (%s, %s, %s, %s, %s)
    """, (ping['trip_id'], ping['driver_id'], ping['lat'], ping['lng'], ping['speed']))
        conn.commit()
        cur.close()
        conn.close()
        for a in anomalies:
            requests.post("http://localhost:8000/internal/broadcast", json={
                "type": "anomaly",
                "data": {
                    "trip_id": ping['trip_id'],
                    "driver_id": ping['driver_id'],
                    "anomaly_type": a['type'],
                    "detail": a['detail'],
                    "severity": a['severity'],
                    "lat": ping['lat'],
                    "lng": ping['lng'],
                    "detected_at": ping['timestamp']
                }
            })

        requests.post("http://localhost:8000/internal/broadcast", json={
            "type": "ping",
            "data": {
                "driver_id": ping['driver_id'],
                "trip_id": ping['trip_id'],
                "lat": ping['lat'],
                "lng": ping['lng'],
                "speed": ping['speed']
            }
        })

        
    else:
        print(f"  ✅ All clear")