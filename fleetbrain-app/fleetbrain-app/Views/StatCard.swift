import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String // Now used visually

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header with icon
            HStack(spacing: 6) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }

            // Value and sub-label
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text(title.lowercased() == "critical" ? "emergencies" : "total incidents")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            // Bottom abstract progress bar
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 24, height: 6)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.cardBorder)
                    .frame(height: 6)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cleanCard()
    }
}
