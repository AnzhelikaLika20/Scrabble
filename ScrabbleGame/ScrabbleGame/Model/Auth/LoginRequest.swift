import Foundation

struct LoginRequest: Codable {
    let username: String
    let email: String
    let password: String
}
