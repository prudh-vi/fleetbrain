from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from db import get_connection
import json

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        print(f"🔌 Client connected. Total: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        print(f"❌ Client disconnected. Total: {len(self.active_connections)}")

    async def broadcast(self, message: dict):
        for connection in self.active_connections.copy():
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Broadcast error: {e}")
                self.active_connections.remove(connection)

manager = ConnectionManager()

# Pydantic model for broadcast
class BroadcastPayload(BaseModel):
    type: str
    data: dict

@app.get("/anomalies")
def get_anomalies():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, trip_id, driver_id, anomaly_type, detail, severity, lat, lng, detected_at
        FROM anomalies ORDER BY detected_at DESC LIMIT 50
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [
        {
            "id": r[0], "trip_id": r[1], "driver_id": r[2],
            "anomaly_type": r[3], "detail": r[4], "severity": r[5],
            "lat": r[6], "lng": r[7], "detected_at": r[8].isoformat()
        }
        for r in rows
    ]

@app.get("/anomalies/stats")
def get_stats():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM anomalies")
    total = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM anomalies WHERE severity = 'CRITICAL'")
    critical = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM anomalies WHERE severity = 'HIGH'")
    high = cur.fetchone()[0]
    cur.execute("SELECT anomaly_type, COUNT(*) FROM anomalies GROUP BY anomaly_type")
    breakdown = {row[0]: row[1] for row in cur.fetchall()}
    cur.close()
    conn.close()
    return {"total": total, "critical": critical, "high": high, "breakdown": breakdown}

@app.get("/pings/latest")
def get_latest_pings():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT driver_id, trip_id, lat, lng, speed, received_at
        FROM gps_pings ORDER BY received_at DESC LIMIT 20
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [
        {
            "driver_id": r[0], "trip_id": r[1], "lat": r[2],
            "lng": r[3], "speed": r[4], "received_at": r[5].isoformat()
        }
        for r in rows
    ]

@app.post("/internal/broadcast")
async def broadcast_anomaly(payload: BroadcastPayload):
    print(f"📡 Broadcasting: {payload.type} to {len(manager.active_connections)} clients")
    await manager.broadcast({"type": payload.type, "data": payload.data})
    return {"status": "broadcasted", "clients": len(manager.active_connections)}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)