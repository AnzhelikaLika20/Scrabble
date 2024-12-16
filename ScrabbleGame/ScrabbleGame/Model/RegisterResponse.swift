import Foundation

struct RegisterResponse: Codable {
    let id: UUID
    let value: String
    let user: User
}
