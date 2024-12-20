import Foundation
import SwiftUI

class RoomViewModel: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var timePerTurn: Int = 0
    @Published var maxPlayers: Int = 0
    @Published var isRoomCreated: Bool = false
    @Published var alertMessage: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var isShowingRoomInfo: Bool = false
    @Published var isSuccess: Bool = false
    @Published var currentRoomId: String = ""
    @Published var invitationCode: String = ""
    @Published var isPlayerInRoom: Bool = false

    
     
    private let authViewModel: AuthViewModel
    
    private let baseURL = "http://127.0.0.1:8080"
    

    @Published var adminID: UUID? = nil
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    func joinRoomByInviteCode(with inviteCode: String) {
        guard !inviteCode.isEmpty else {
            alertMessage = "Пожалуйста, введите корректный пригласительный код."
            isShowingAlert = true
            return
        }
        let joinRoomRequest = JoinRoomByInvitationCodeRequest(inviteCode: inviteCode)
        joinRoomRequestAPI(joinRoomRequest: joinRoomRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let room):
                    self.alertMessage = "Вы успешно присоединились к комнате."
                    self.isShowingAlert = false
                    self.currentRoomId = room
                    self.isSuccess = true
                    self.isShowingRoomInfo = true
                case .failure( _):
                    self.alertMessage = "Не удалось присоединиться к комнате. Попробуйте еще раз."
                    self.isShowingAlert = true
                    self.isSuccess = false
                }
            }
        }
    }


    
    func joinRandomPublicRoom() {
           joinRandomPublicRoomAPI { result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let message):
                       self.alertMessage = message
                       self.isShowingAlert = true
                       self.isSuccess = true
                   case .failure(let error):
                       self.alertMessage = "Не удалось присоединиться к комнате: \(error.localizedDescription)"
                       self.isShowingAlert = true
                       self.isSuccess = false
                   }
               }
           }
       }
    
    
    private func joinRandomPublicRoomAPI(completion: @escaping (Result<String, Error>) -> Void) {
            guard let url = URL(string: "\(baseURL)/rooms/joinRandomPublic") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let accessToken = authViewModel.accessToken
            if let token = accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Отсутствует токен доступа"])))
                return
            }
            //request.setValue("Bearer rRT2nYd9cCELM1IZPixdI7zX9YH6cj3VMaNNJT77mOY=", forHTTPHeaderField: "Authorization")
            
            let parameters: [String: Any] = [
                "inviteCode": "inviteCode"
            ]

            if let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
                request.httpBody = httpBody
            }
           
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
                
                guard let data = data,
                      let responseString = String(data: data, encoding: .utf8) else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                    }
                    return
                }
                
                if (responseString.contains("Database error")) {
                    DispatchQueue.main.async {
                        self.isPlayerInRoom = true
                        completion(.success("Вы находитесь в комнате"))
                    }
                
                    return
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(responseString))
                }
            }
            task.resume()
        }

    
    func createRoom() {
        guard timePerTurn > 0, maxPlayers > 1 else {
            alertMessage = "Пожалуйста, выберите корректное время на ход и максимальное количество игроков"
            isShowingAlert = true
            return
        }
        
        let createRoomRequest = CreateRoomRequest(isPrivate: isPrivate, timePerTurn: timePerTurn, maxPlayers: maxPlayers)
        createRoomRequestAPI(createRoomRequest: createRoomRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.alertMessage = message
                    self.isRoomCreated = true
                    self.isSuccess = true
                    self.isShowingRoomInfo = true
                case .failure(_):
                    self.alertMessage = "Не удалось создать комнату. Попробуйте еще раз."
                    self.isShowingAlert = true
                    self.isSuccess = false
                }
            }
        }
    }
    
    private func createRoomRequestAPI(createRoomRequest: CreateRoomRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/rooms/create") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let accessToken = authViewModel.accessToken
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Отсутствует токен доступа"])))
            return
        }
        

        let jsonData = try? JSONEncoder().encode(createRoomRequest)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных от сервера"])))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CreateRoomResponse.self, from: data)
                DispatchQueue.main.async {
                    self.invitationCode = response.inviteCode
                    self.adminID = response.adminID
                    self.maxPlayers = response.maxPlayers
                    self.timePerTurn = response.timePerTurn
                    self.alertMessage = "Комната успешно создана. Пригласительный код: \(response.inviteCode)"
                    completion(.success("Комната успешно создана"))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    private func joinRoomRequestAPI(joinRoomRequest: JoinRoomByInvitationCodeRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/rooms/joinByInviteCode") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let accessToken = authViewModel.accessToken
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Отсутствует токен доступа"])))
            return
        }
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(joinRoomRequest)
        } catch {
            completion(.failure(error))
            return
        }
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных от сервера"])))
                }
                return
            }
            
            do {
                let roomDTO = try JSONDecoder().decode(JoinRoomByInvitationCodeResponse.self, from: data)
                DispatchQueue.main.async {
                    self.maxPlayers = roomDTO.maxPlayers
                    self.invitationCode = roomDTO.inviteCode
                    self.timePerTurn = roomDTO.timePerTurn
                    completion(.success("Вы успешно присоединились к комнате"))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
