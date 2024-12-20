import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var roomViewModel: RoomViewModel
    @State private var isCreatingRoom: Bool = false
    @State private var isJoiningRoomByInviteCode: Bool = false

    // Custom initializer to pass `authViewModel` to `roomViewModel`
    init(authViewModel: AuthViewModel) {
        // Using `@EnvironmentObject` for dependency injection
        _roomViewModel = StateObject(wrappedValue: RoomViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Scrabble Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Button(action: {
                    roomViewModel.fetchPublicRooms()
                }) {
                    Text("View Public Rooms")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $roomViewModel.isShowingRoomList) {
                    PublicRoomsView(roomViewModel: roomViewModel)
                }

                
                Button(action: {
                    isCreatingRoom = true
                }) {
                    Text("Create Room")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    Text("Join Room")
                        .font(.headline)

                    HStack {
                        Button(action: joinRandomRoom) {
                            Text("Join Random Public Room")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {isJoiningRoomByInviteCode = true}) {
                            Text("Join Room by Invite Code")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $roomViewModel.isPlayerInRoom) {
                            Alert(
                                title: Text(roomViewModel.isSuccess ? "Успех" : "Ошибка"),
                                message: Text(roomViewModel.alertMessage),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: logOut) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarHidden(true)
            .sheet(isPresented: $isCreatingRoom) {
                CreateRoomModalView(roomViewModel: roomViewModel)
            }
            .sheet(isPresented: $isJoiningRoomByInviteCode) {
                InvitationCodeView(roomJoiningViewModel: roomViewModel)
            }
        }
    }

    func joinRandomRoom() {
        roomViewModel.joinRandomPublicRoom()
    }

    func logOut() {
        authViewModel.logOut()
    }
}

