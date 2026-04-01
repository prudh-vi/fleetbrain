//
//  AnomalyChart.swift
//  fleetbrain-app
//
//  Created by Prudhvii on 01/04/26.
//

import SwiftUI
import Charts

struct AnomalyChart: View {
    var anomalies: [Anomaly]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 32, height: 32)
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                
                Text("Events by Type")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            Chart {
                ForEach(groupedData(), id: \.type) { item in
                    BarMark(
                        x: .value("Type", item.type.replacingOccurrences(of: "_", with: "\n").capitalized),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(color(for: item.type))
                    .cornerRadius(4)
                }
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine().foregroundStyle(Color.cardBorder)
                    AxisValueLabel().foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(20)
        .cleanCard()
    }

    func groupedData() -> [(type: String, count: Int)] {
        let dict = Dictionary(grouping: anomalies, by: { $0.anomaly_type })
        return dict.map { ($0.key, $0.value.count) }
    }

    func color(for type: String) -> Color {
        switch type {
        case "OVERSPEED": return .accent
        case "ROUTE_DEVIATION": return .primary
        case "DRIVER_SILENT": return .danger
        default: return .gray
        }
    }
}
