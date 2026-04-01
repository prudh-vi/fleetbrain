# ⚡ FleetBrain

> Real-time fleet anomaly detection platform — built from the ground up to solve the exact problems enterprise mobility systems face at scale.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat-square&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white)
![Kafka](https://img.shields.io/badge/Apache_Kafka-231F20?style=flat-square&logo=apache-kafka&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=swift&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)

---

## The Problem

At 43M trips/year (~118,000 trips/day), even a **1% failure rate = 1,180 bad trips daily**. Enterprise mobility platforms sell safety and reliability to Fortune 500 clients. A single incident — a driver deviating from route, speeding through a residential zone, or going silent mid-trip — is a client relationship at risk.

**FleetBrain catches these problems before they become incidents.**

---

## Architecture

```
Driver Phone (GPS)
      ↓  every 3s
  Kafka Topic: gps-pings
      ↓
  Anomaly Engine (Python)
  ├── Route Deviation  →  Haversine formula vs expected polyline
  ├── Overspeeding     →  speed threshold per zone
  └── Driver Silence   →  ping gap detection
      ↓
  PostgreSQL           →  persist alerts with coordinates + severity
      ↓
  FastAPI              →  REST + WebSocket
      ↓
  iOS App (SwiftUI)    →  live map + instant anomaly alerts
```

---

## Features

- **Real-time GPS telemetry pipeline** via Apache Kafka — one ping every 3 seconds per driver
- **Multi-rule anomaly detection** — route deviation (Haversine), overspeeding, driver silence
- **Sub-100ms alert delivery** via WebSockets — no polling, pure push
- **Native iOS app** in SwiftUI with live MapKit tracking and anomaly feed
- **PostgreSQL persistence** — every alert stored with timestamp, coordinates, severity
- **Trip simulator** — inject anomalies on demand for testing and demos
- **Full stack containerized** — entire backend spins up with one command

---

## Stack

| Layer | Technology |
|---|---|
| iOS App | Swift, SwiftUI, MapKit, WebSockets |
| API | Python, FastAPI |
| Event Streaming | Apache Kafka |
| Anomaly Detection | Python (Haversine, rule-based engine) |
| Database | PostgreSQL |
| Containerization | Docker, Docker Compose |
| Architecture | MVVM (iOS), Microservices (backend) |

---

## Getting Started

### Prerequisites
- Docker Desktop
- Python 3.11+
- Xcode 15+ (for iOS app)

### 1. Clone the repo

```bash
git clone https://github.com/prudh-vi/fleetbrain
cd fleetbrain
```

### 2. Start the backend

```bash
# Spin up Kafka + Zookeeper + PostgreSQL
docker compose up -d

# Create Kafka topic
docker exec -it fleetbrain-kafka-1 kafka-topics \
  --create --topic gps-pings \
  --bootstrap-server localhost:9092 \
  --partitions 1 --replication-factor 1

# Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Initialize database
python db.py

# Start the API
python -m uvicorn api:app --reload --port 8000
```

### 3. Run the anomaly engine

```bash
# In a new terminal (venv activated)
python anomaly_engine.py
```

### 4. Simulate a trip

```bash
# Normal trip
python simulator.py

# Trip with anomalies injected
# Set inject_anomaly=True in simulator.py, then:
python simulator.py
```

### 5. Open the iOS app

Open `fleetbrain-app/FleetBrain.xcodeproj` in Xcode and run on simulator or device.

---

## Anomaly Detection Logic

### Route Deviation
Every ping is checked against the expected route polyline using the **Haversine formula** — calculating great-circle distance between the driver's current coordinates and the nearest point on the expected path. If deviation exceeds **300m for 3 consecutive pings**, an alert fires.

```python
def haversine(lat1, lng1, lat2, lng2):
    R = 6371000  # Earth radius in meters
    φ1, φ2 = math.radians(lat1), math.radians(lat2)
    Δφ = math.radians(lat2 - lat1)
    Δλ = math.radians(lng2 - lng1)
    a = math.sin(Δφ/2)**2 + math.cos(φ1) * math.cos(φ2) * math.sin(Δλ/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
```

### Overspeeding
Speed is checked against a configurable threshold (default 80 km/h). Adjustable per zone type — residential, highway, campus.

### Driver Silence
If no ping is received from an active driver for more than **10 seconds**, a CRITICAL alert fires. In production this catches device failures, accidents, or network drops.

---

## Demo

Run the simulator with `inject_anomaly=True` and watch the iOS app receive alerts in real time:

```
📍 Ping received: (12.98, 77.76) | 107 km/h
  ⚠️  ANOMALY [ROUTE_DEVIATION] — Driver is 2681m off expected route
  🔴 ANOMALY [OVERSPEED] — Driver doing 107 km/h — limit is 80 km/h
```

Alerts appear on the iOS map as pins within **100ms** of detection.

---

## Project Structure

```
fleetbrain/
├── fleetbrain-app/        # SwiftUI iOS app
│   └── FleetBrain/
│       ├── Models/
│       ├── ViewModels/
│       └── Views/
├── anomaly_engine.py      # Kafka consumer + anomaly detection
├── simulator.py           # GPS trip simulator with anomaly injection
├── api.py                 # FastAPI REST + WebSocket server
├── db.py                  # PostgreSQL connection + schema
├── docker-compose.yml     # Kafka + Zookeeper + PostgreSQL
└── requirements.txt
```

---

## Roadmap

- [ ] ETA prediction ML model trained on historical trip data
- [ ] Driver risk scoring (cumulative anomaly history)
- [ ] Grafana metrics dashboard
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Multi-driver support with concurrent trip tracking

---

## Why I Built This

MoveInSync manages 43M trips/year across 85K vehicles. The hardest problem in fleet ops isn't routing — it's knowing something is wrong **before** the driver calls in. FleetBrain is my attempt at that system, built from scratch.

---

<p align="center">Built by <a href="https://github.com/prudh-vi">Prudhvi</a></p>