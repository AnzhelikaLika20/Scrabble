import SwiftUI


struct InvitationCodeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var roomJoiningViewModel: RoomViewModel
    @State private var isShowingInfo: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Invitate Code")
                .font(.title)
                .padding()

            TextField("Invite Code", text: $roomJoiningViewModel.invitationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                isShowingInfo = true
            }) {
                Text("Join Room")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

        }
        .padding()
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingInfo) {
            RoomInfoView(
                playerCount: roomJoiningViewModel.maxPlayers,
                timePerMove: roomJoiningViewModel.timePerTurn,
                inviteCode: roomJoiningViewModel.invitationCode)
        }
    }
}
