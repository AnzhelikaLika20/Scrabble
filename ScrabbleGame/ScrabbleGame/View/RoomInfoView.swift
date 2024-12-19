import SwiftUI

struct RoomInfoView: View {
    let playerCount: Int
    let timePerMove: Int
    let inviteCode: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Room Information")
                .font(.largeTitle)
                .padding()
            
            HStack {
                Text("Allowed Players:")
                Spacer()
                Text("\(playerCount)")
            }
            .padding()

            HStack {
                Text("Time per Move:")
                Spacer()
                Text("\(timePerMove) seconds")
            }
            .padding()

            HStack {
                Text("Invite Code:")
                Spacer()
                Text(inviteCode)
            }
            .padding()
        }
        .padding()
    }
}
