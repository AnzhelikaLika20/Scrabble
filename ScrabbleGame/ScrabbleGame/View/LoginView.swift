import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Авторизация")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Пароль", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.none)
                    .padding(.horizontal)
                
                Button(action: viewModel.login) {
                    Text("Войти")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .alert(isPresented: $viewModel.isShowingAlert) {
                    Alert(title: Text("Ошибка"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: RegisterView()) {
                    Text("Нет аккаунта? Зарегистрируйтесь")
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}
