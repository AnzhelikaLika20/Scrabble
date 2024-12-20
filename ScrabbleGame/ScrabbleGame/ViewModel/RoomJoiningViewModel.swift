import SwiftUI

class RoomJoiningViewModel: ObservableObject {
    @Published var invitationCode: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
}
