import Foundation

struct User: Codable {
    let id: UUID
    let username: String
    let email: String
}
