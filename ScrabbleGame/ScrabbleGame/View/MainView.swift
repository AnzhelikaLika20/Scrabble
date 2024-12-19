import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var roomViewModel: RoomViewModel
    @State private var isCreatingRoom: Bool = false

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

                        Button(action: joinByInvitationRoom) {
                            Text("Join by Invitation Room")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
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
                CreateRoomModalView(roomViewModel: roomViewModel)  // Modal view for creating room
            }
        }
    }

    func joinRandomRoom() {
        // Handle joining random room action
    }

    func joinByInvitationRoom() {
        // Handle joining by invitation room action
    }

    func logOut() {
        authViewModel.logOut()
    }
}

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
                roomViewModel.createRoom()  // Trigger create room action
            }) {
                Text("Create Room")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                roomViewModel.isShowingAlert = false  // Dismiss modal if cancelled
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onChange(of: roomViewModel.isShowingAlert) { _ in
            if roomViewModel.isShowingAlert {
                // Show alert with message
                let alert = UIAlertController(title: "Room Creation", message: roomViewModel.alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
            }
        }
    }
}
