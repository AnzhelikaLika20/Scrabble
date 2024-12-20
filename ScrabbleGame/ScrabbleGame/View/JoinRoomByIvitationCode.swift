import SwiftUI

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
                Alert(title: Text("Ошибка"), message: Text(roomJoiningViewModel.alertMessage))}
        }
        .padding()
        .navigationBarHidden(true)
    }
}
