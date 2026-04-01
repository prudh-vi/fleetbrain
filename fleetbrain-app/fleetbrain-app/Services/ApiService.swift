import Foundation

class APIService {
    static let shared = APIService()

    let baseURL = "http://192.168.0.104:8000"

    func fetchAnomalies(completion: @escaping ([Anomaly]) -> Void) {
        guard let url = URL(string: "\(baseURL)/anomalies") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let decoded = try? JSONDecoder().decode([Anomaly].self, from: data)
                DispatchQueue.main.async {
                    completion(decoded ?? [])
                }
            }
        }.resume()
    }
}
