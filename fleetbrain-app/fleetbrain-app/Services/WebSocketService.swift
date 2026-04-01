import Foundation
import Combine

// Wrapper model coming from backend
struct WSWrapper: Decodable {
    let type: String
    let data: Anomaly
}

class WebSocketService: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    private var task: URLSessionWebSocketTask?

    func connect(onMessage: @escaping (Anomaly) -> Void) {
        guard let url = URL(string: "ws://192.168.0.104:8000/ws") else { return }

        print("🔌 Connecting to WebSocket...")

        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()

        receive(onMessage: onMessage)
    }

    private func receive(onMessage: @escaping (Anomaly) -> Void) {
        task?.receive { result in
            switch result {

            case .success(let message):
                switch message {

                case .string(let text):
                    print("📡 WS RAW:", text)

                    guard let data = text.data(using: .utf8) else { return }

                    do {
                        let decoded = try JSONDecoder().decode(WSWrapper.self, from: data)

                        if decoded.type == "anomaly" {
                            DispatchQueue.main.async {
                                print("🔥 New anomaly received!")
                                onMessage(decoded.data)
                            }
                        }

                    } catch {
                        print("❌ Decode error:", error)
                    }

                case .data(let data):
                    print("📡 WS DATA:", data)

                @unknown default:
                    break
                }

            case .failure(let error):
                print("❌ WebSocket error:", error)
            }

            // keep listening
            self.receive(onMessage: onMessage)
        }
    }

    func disconnect() {
        print("🔌 WebSocket disconnected")
        task?.cancel(with: .goingAway, reason: nil)
    }
}
