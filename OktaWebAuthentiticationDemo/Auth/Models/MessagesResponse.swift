import Foundation

struct MessageResponse: Codable {
    let messages: [Message]
}

struct Message: Codable {
    let date: String
    let text: String
}
