import SwiftUI
import MapKit

struct MapView: View {
    var anomalies: [Anomaly]

    @State private var vehicleCoord = CLLocationCoordinate2D(latitude: 12.97, longitude: 77.70)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 32, height: 32)
                    Image(systemName: "map.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                Text("Live Tracking")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Map {
                // Route
                MapPolyline(coordinates: route)
                    .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                // Points
                ForEach(anomalies, id: \.uuid) { a in
                    if let lat = a.lat, let lng = a.lng {
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                            Circle()
                                .fill(a.severity == "CRITICAL" ? Color.danger : Color.accent)
                                .frame(width: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: Color.black.opacity(0.1), radius: 4)
                        }
                    }
                }

                // Vehicle (animated)
                Annotation("Vehicle", coordinate: vehicleCoord) {
                    ZStack {
                        Circle()
                            .fill(Color.accent.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.black.opacity(0.15), radius: 4)
                            Image(systemName: "box.truck.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.accent)
                        }
                    }
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .cleanCard()
        .onAppear {
            animateVehicle()
        }
    }

    var route: [CLLocationCoordinate2D] {
        anomalies.compactMap {
            if let lat = $0.lat, let lng = $0.lng {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            return nil
        }
    }

    func animateVehicle() {
        guard let latest = anomalies.first,
              let lat = latest.lat,
              let lng = latest.lng else { return }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            vehicleCoord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
}
