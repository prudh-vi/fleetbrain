import psycopg2

def get_connection():
    return psycopg2.connect(
        dbname="fleetbrain",
        user="admin",
        password="admin123",
        host="localhost",
        port="5433"
    )

def setup_db():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS trips (
            trip_id VARCHAR(50) PRIMARY KEY,
            driver_id VARCHAR(50),
            status VARCHAR(20) DEFAULT 'ACTIVE',
            started_at TIMESTAMP DEFAULT NOW()
        );
    """)

    cur.execute("""
        CREATE TABLE IF NOT EXISTS gps_pings (
            id SERIAL PRIMARY KEY,
            trip_id VARCHAR(50),
            driver_id VARCHAR(50),
            lat DOUBLE PRECISION,
            lng DOUBLE PRECISION,
            speed INT,
            received_at TIMESTAMP DEFAULT NOW()
        );
    """)

    cur.execute("""
        CREATE TABLE IF NOT EXISTS anomalies (
            id SERIAL PRIMARY KEY,
            trip_id VARCHAR(50),
            driver_id VARCHAR(50),
            anomaly_type VARCHAR(50),
            detail TEXT,
            severity VARCHAR(20),
            lat DOUBLE PRECISION,
            lng DOUBLE PRECISION,
            detected_at TIMESTAMP DEFAULT NOW()
        );
    """)

    conn.commit()
    cur.close()
    conn.close()
    print("✅ Database tables ready")

if __name__ == "__main__":
    setup_db()