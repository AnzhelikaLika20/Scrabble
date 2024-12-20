import SwiftUI


struct CreateRoomModalView: View {
    @ObservedObject var roomViewModel: RoomViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Room")
                .font(.headline)

            Toggle(isOn: $roomViewModel.isPrivate) {
                Text("Private Room")
            }

            HStack {
                Text("Time per Turn (seconds):")
                TextField("Enter time", value: $roomViewModel.timePerTurn, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }

            HStack {
                Text("Max Players:")
                TextField("Enter max players", value: $roomViewModel.maxPlayers, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }

            Button(action: {
                roomViewModel.createRoom()
            }) {
                Text("Create Room")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        
        .sheet(isPresented: $roomViewModel.isShowingRoomInfo) {
            RoomInfoView(
                playerCount: roomViewModel.maxPlayers,
                timePerMove: roomViewModel.timePerTurn,
                inviteCode: roomViewModel.invitationCode)
        }
//        .onChange(of: roomViewModel.isShowingAlert) { _ in
//            if roomViewModel.isShowingAlert {
//                // Show alert with message
//                let alert = UIAlertController(title: "Room Creation", message: roomViewModel.alertMessage, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
//            }
//        }
    }
}
