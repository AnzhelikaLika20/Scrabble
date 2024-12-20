import SwiftUI

struct PublicRoomsView: View {
    @ObservedObject var roomViewModel: RoomViewModel

    var body: some View {
        NavigationView {
            List(roomViewModel.publicRooms, id: \.id) { room in
                VStack(alignment: .leading, spacing: 5) {
                    Text("Room ID: \(room.id?.uuidString ?? "N/A")")
                        .font(.headline)
                    Text("Admin ID: \(room.adminID.uuidString)")
                    Text("Invite Code: \(room.inviteCode)")
                    Text("Game Status: \(room.gameStatus)")
                    Text("Time Per Turn: \(room.timePerTurn)")
                    Text("Max Players: \(room.maxPlayers)")
                }
                .padding()
            }
            .navigationBarTitle("Public Rooms", displayMode: .inline)
            .toolbar {
                Button("Close") {
                    roomViewModel.isShowingRoomList = false
                }
            }
        }
    }
}
