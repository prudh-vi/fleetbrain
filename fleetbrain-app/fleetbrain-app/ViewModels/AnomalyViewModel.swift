//
//  1.swift
//  fleetbrain-app
//
//  Created by Prudhvii on 01/04/26.
//

import Foundation
import Combine

class AnomalyViewModel: ObservableObject {
    @Published var anomalies: [Anomaly] = []

    func loadData() {
        APIService.shared.fetchAnomalies { data in
            self.anomalies = data
        }
    }
}
