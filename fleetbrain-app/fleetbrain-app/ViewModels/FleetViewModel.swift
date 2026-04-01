import Foundation
import Combine
import SwiftUI

class FleetViewModel: ObservableObject {
    @Published var anomalies: [Anomaly] = []

    private let ws = WebSocketService()

    var criticalCount: Int {
        anomalies.filter { $0.severity == "CRITICAL" }.count
    }

    var overspeedCount: Int {
        anomalies.filter { $0.anomaly_type == "OVERSPEED" }.count
    }

    var insight: String {
        if overspeedCount > 5 {
            return "⚠️ Driver showing repeated overspeed behavior"
        }
        return "Fleet operating normally"
    }

    func loadInitial() {
        APIService.shared.fetchAnomalies { data in
            self.anomalies = data
        }
    }

    func startLiveUpdates() {
        ws.connect { new in
            withAnimation(.spring()) {
                self.anomalies.insert(new, at: 0)
            }
        }
    }
}
