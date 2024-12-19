import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Имя пользователя", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Пароль", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.none)
                .padding(.horizontal)

            TextField("Подтвердите пароль", text: $viewModel.confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.none)
                .padding(.horizontal)
            
            Button(action: viewModel.register) {
                Text("Зарегистрироваться")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $viewModel.isShowingAlert) {
                Alert(
                    title: Text(viewModel.isSuccess ? "Успех" : "Ошибка"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

            
            NavigationLink(destination: LoginView()) {
                Text("Уже есть аккаунт? Войдите")
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.top)
        }
        .padding()
    }
}
