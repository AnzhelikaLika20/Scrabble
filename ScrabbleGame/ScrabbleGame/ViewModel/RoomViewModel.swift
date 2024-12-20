import Foundation
import SwiftUI

class RoomViewModel: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var timePerTurn: Int = 30
    @Published var maxPlayers: Int = 4
    @Published var isRoomCreated: Bool = false
    @Published var alertMessage: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var isShowingRoomInfo: Bool = false
    @Published var isSuccess: Bool = true
    @Published var currentRoomId: String = ""
    @Published var roomDetails: (playerCount: Int, timePerMove: Int, inviteCode: String)? = nil
    @Published var invitationCode: String = ""
    
     
    
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
                    self.isShowingAlert = true
                    self.currentRoomId = room
                    self.isSuccess = true
                    self.isShowingRoomInfo = true
                    self.roomDetails = (
                                            playerCount: 4,
                                            timePerMove: 60,
                                            inviteCode: inviteCode
                                        )
                case .failure(let error):
                    self.alertMessage = "Не удалось присоединиться к комнате. Попробуйте еще раз."
                    self.isShowingAlert = true
                    self.isSuccess = false
                }
            }
        }
    }


    
    func joinRandomPublicRoom() {
        
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
        
//        let accessToken = "mnT84B8ZhLPTpo5HenIYlWJUybcR1GE75P+9zyiNyJA="
//        request.setValue("Bearer mnT84B8ZhLPTpo5HenIYlWJUybcR1GE75P+9zyiNyJA=", forHTTPHeaderField: "Authorization")
        
        if let token = authViewModel.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Отсутствует токен доступа"])))
            return
        }
        
        // Encode the request body
        let jsonData = try? JSONEncoder().encode(createRoomRequest)
        request.httpBody = jsonData
        
        // Perform the network request
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
