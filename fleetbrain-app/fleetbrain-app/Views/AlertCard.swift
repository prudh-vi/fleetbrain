import SwiftUI

struct AlertCard: View {
    let anomaly: Anomaly

    var color: Color {
        anomaly.severity == "CRITICAL" ? .danger : .accent
    }

    var icon: String {
        switch anomaly.anomaly_type {
        case "OVERSPEED": return "speedometer"
        case "ROUTE_DEVIATION": return "map.fill"
        case "DRIVER_SILENT": return "mic.slash.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Left icon block
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }

            // Info text
            VStack(alignment: .leading, spacing: 4) {
                Text(anomaly.anomaly_type.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                HStack(spacing: 6) {
                    Text(anomaly.driver_id)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(Color.cardBorder)
                    
                    Text("Trip \(anomaly.trip_id)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            // Right side stats/details
            VStack(alignment: .trailing, spacing: 6) {
                Text(anomaly.severity)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(color)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                
                Text("Just now")
                    .font(.system(size: 10))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .cleanCard()
    }
}
