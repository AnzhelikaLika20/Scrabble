import Foundation

struct CreateRoomRequest : Codable {
    let isPrivate: Bool
    let timePerTurn: Int
    let maxPlayers: Int
}
