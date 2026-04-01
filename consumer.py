import json
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'gps-pings',
    bootstrap_servers='localhost:9092',
    value_deserializer=lambda v: json.loads(v.decode('utf-8')),
    auto_offset_reset='earliest'
)

print("👂 Listening for GPS pings...\n")

for message in consumer:
    ping = message.value
    print(f"🚗 Driver {ping['driver_id']} | Trip {ping['trip_id']} | ({ping['lat']}, {ping['lng']}) | {ping['speed']} km/h")