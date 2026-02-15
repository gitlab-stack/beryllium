// local http server - serves a single html page on localhost
// used to serve the "add to home screen" shortcut page to safari.
// built on the Network framework (no dependencies).

import Foundation
import Network

class LocalServer {
    private var listener: NWListener?
    private var responseData: Data?
    private var autoStopTimer: Timer?

    var port: UInt16? {
        listener?.port?.rawValue
    }

    func start(html: String, completion: @escaping (UInt16?) -> Void) {
        // stop any existing listener first
        stop()
        responseData = html.data(using: .utf8)

        do {
            listener = try NWListener(using: .tcp, on: .any)
        } catch {
            completion(nil)
            return
        }

        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                let port = self?.listener?.port?.rawValue
                completion(port)
                // auto-stop after 5 minutes to avoid resource leaks
                self?.autoStopTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { _ in
                    self?.stop()
                }
            case .failed:
                completion(nil)
            default:
                break
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handle(connection)
        }

        listener?.start(queue: .main)
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: .main)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] _, _, _, _ in
            guard let data = self?.responseData else {
                connection.cancel()
                return
            }
            let header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(data.count)\r\nCache-Control: no-cache\r\nConnection: close\r\n\r\n"
            var response = Data(header.utf8)
            response.append(data)
            connection.send(content: response, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    func stop() {
        autoStopTimer?.invalidate()
        autoStopTimer = nil
        listener?.cancel()
        listener = nil
    }
}
