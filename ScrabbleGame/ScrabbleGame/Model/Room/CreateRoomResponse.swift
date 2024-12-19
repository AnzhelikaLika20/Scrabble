import Foundation

struct CreateRoomResponse : Codable {
    let inviteCode: String
    let adminID: UUID
}
