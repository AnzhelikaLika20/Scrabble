import SwiftUI

@main
struct ScrabbleGameApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainView(authViewModel: authViewModel)
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
