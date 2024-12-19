struct JoinRoomByInvitationCodeResponse: Codable {
    let id: String
    let currentUserID: String
    let inviteCode: String
    let isPrivate: Bool
    let adminID: String
    let timePerTurn: Int
    let maxPlayers: Int
}
