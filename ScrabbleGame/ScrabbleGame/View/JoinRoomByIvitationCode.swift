struct InvitationCodeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var roomJoiningViewModel: RoomViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Invitate Code")
                .font(.title)
                .padding()

            TextField("Invite Code", text: $roomJoiningViewModel.invitationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                roomJoiningViewModel.joinRoomByInviteCode(with: roomJoiningViewModel.invitationCode)
            }) {
                Text("Join Room")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .sheet(isPresented: $roomJoiningViewModel.isSuccess) {
                RoomInfoView(playerCount: roomJoiningViewModel.maxPlayers, timePerMove: roomJoiningViewModel.timePerTurn, inviteCode: roomJoiningViewModel.invitationCode)
            }
            .alert(isPresented: $roomJoiningViewModel.isShowingAlert) {
                Alert(title: Text("Ошибка"), message: Text(roomJoiningViewModel.alertMessage ?? ""))}
        }
        .padding()
        .navigationBarHidden(true)
    }
}

import SwiftUI

class RoomJoiningViewModel: ObservableObject {
    @Published var invitationCode: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func joinByInvitation() {
        isLoading = true
        errorMessage = nil

        guard !invitationCode.isEmpty else {
            errorMessage = "Please enter a valid invitation code."
            isLoading = false
            return
        }

        DispatchQueue.global().async {
            sleep(2) // Симуляция сетевого запроса

            let success = Bool.random() // Случайный успех для примера
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    print("Successfully joined by invitation code: \(self.invitationCode)")
                } else {
                    self.errorMessage = "Failed to join with the provided invitation code."
                }
            }
        }
    }
}
