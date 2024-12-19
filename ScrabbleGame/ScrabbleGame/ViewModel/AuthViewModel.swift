import Foundation

class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var alertMessage: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var isSuccess: Bool = true
    @Published var accessToken: String? = nil
    
    private let baseURL = "http://127.0.0.1:8080"
    
    func register() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Пожалуйста, заполните все поля"
            isShowingAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Пароли не совпадают"
            isShowingAlert = true
            return
        }
        
        let registerRequest = RegisterRequest(username: username, email: email, password: password)
        registerUser(registerRequest: registerRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.alertMessage = message
                    self.isShowingAlert = true
                    self.isLoggedIn = true
                    self.isSuccess = true
                case .failure(let error):
                    self.alertMessage = "Не удалось создать нового пользователя. Попробуйте не пробовать..."
                    self.isShowingAlert = true
                    self.isSuccess = false
                }
            }
        }
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Пожалуйста, заполните все поля"
            isShowingAlert = true
            return
        }
        
//        let user = User(username: "", email: email, password: password)
//        loginUser(user: user) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let message):
//                    self.alertMessage = message
//                    self.isLoggedIn = true
//                case .failure(let error):
//                    self.alertMessage = error.localizedDescription
//                    self.isShowingAlert = true
//                }
//            }
//        }
    }
    
    private func registerUser(registerRequest: RegisterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/auth/register") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONEncoder().encode(registerRequest)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных от сервера"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
                self.accessToken = response.value
                completion(.success("Вы успешно зарегистрировались"))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func loginUser(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/auth/login") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //let loginString = "\(user.email):\(user.password)"
        let loginString = "placeholder"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка авторизации"])))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных от сервера"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
                completion(.success("Вы успешно авторизовались"))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
