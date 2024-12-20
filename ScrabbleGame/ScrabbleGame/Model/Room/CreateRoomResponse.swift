import Foundation

struct CreateRoomResponse : Codable {
    let inviteCode: String
    let adminID: UUID
    let timePerTurn: Int
    let maxPlayers: Int
}
