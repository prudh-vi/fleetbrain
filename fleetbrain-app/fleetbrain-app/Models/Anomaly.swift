import Foundation

struct Anomaly: Identifiable, Decodable {
    let id: Int?
    let trip_id: String
    let driver_id: String
    let anomaly_type: String
    let detail: String
    let severity: String
    let lat: Double?
    let lng: Double?
    let detected_at: String?

    var uuid: UUID { UUID() }
}
