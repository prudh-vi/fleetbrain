import json
import time
import random
from kafka import KafkaProducer

# Real Bangalore route coordinates (Whitefield → MoveInSync office area)
ROUTE = [
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

# Anomaly route — deviates from above
ANOMALY_COORDS = [
    (12.9800, 77.7600),
    (12.9820, 77.7650),
    (12.9840, 77.7700),
]

producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def simulate_trip(inject_anomaly=False):
    route = ROUTE.copy()

    # Inject anomaly at midpoint if flag is set
    if inject_anomaly:
        midpoint = len(route) // 2
        route[midpoint:midpoint] = ANOMALY_COORDS
        print("⚠️  ANOMALY INJECTED — driver will deviate mid-route")

    for i, (lat, lng) in enumerate(route):
        ping = {
            "driver_id": "D-4821",
            "trip_id": "T-99231",
            "lat": lat,
            "lng": lng,
            "speed": random.randint(30, 70) if not inject_anomaly else random.randint(80, 110),
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "ping_index": i
        }

        producer.send('gps-pings', ping)
        print(f"📍 Sent ping {i+1}: ({lat}, {lng}) | speed: {ping['speed']} km/h")
        time.sleep(3)  # one ping every 3 seconds, like a real driver app

    print("✅ Trip complete")

# Change to True to simulate anomaly
simulate_trip(inject_anomaly=True)