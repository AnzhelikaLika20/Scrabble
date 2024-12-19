import Foundation

struct LoginResponse: Codable {
    let id: String
    let user: User
    let value: String
}
