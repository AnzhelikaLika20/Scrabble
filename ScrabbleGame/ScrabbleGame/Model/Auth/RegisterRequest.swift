import Foundation

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}
