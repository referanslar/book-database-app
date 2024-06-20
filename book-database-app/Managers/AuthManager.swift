import UIKit
import Alamofire

class AuthManager {

    static let shared = AuthManager()

    private init() {}

    internal(set) var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "accessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }

    internal(set) var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "refreshToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "refreshToken")
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool, ErrorResponse?) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]

        AF.request(LOGIN_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let loginResponse):
                self.accessToken = loginResponse.tokens.accessToken
                self.refreshToken = loginResponse.tokens.refreshToken
                completion(true, nil)
            case .failure:
                if let data = response.data {
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        completion(false, errorResponse)
                    } catch {
                        completion(false, nil)
                    }
                } else {
                    completion(false, nil)
                }
            }
        }
    }

    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken else {
            completion(false)
            return
        }

        let parameters: [String: Any] = [
            "refreshToken": refreshToken
        ]

        AF.request(REFRESH_URL, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: RefreshResponse.self) { response in
            switch response.result {
            case .success(let refreshResponse):
                self.accessToken = refreshResponse.tokens.accessToken
                self.refreshToken = refreshResponse.tokens.refreshToken
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func clearTokens() {
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            self.accessToken = nil
            self.refreshToken = nil
        }
        
        func signOut(completion: @escaping (Bool) -> Void) {
            guard let refreshToken = self.refreshToken else {
                completion(false)
                return
            }
            
            let parameters: [String: Any] = [
                "refreshToken": refreshToken
            ]
            
            AF.request(LOGOUT_URL, method: .delete, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: [200, 204, 401]).response { response in
                if let statusCode = response.response?.statusCode {
                    print("Status Code: \(statusCode)")
                }
                
                switch response.result {
                case .success:
                    self.clearTokens()
                    completion(true)
                    
                case .failure(let error):
                    if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                        print("Response data: \(json)")
                    }
                    print("Sign out error: \(error.localizedDescription)")
                    self.clearTokens()
                    completion(true)
                }
            }
        }
}


class AuthInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let accessToken = AuthManager.shared.accessToken {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        AuthManager.shared.refreshToken { success in
            if success {
                completion(.retry)
            } else {
                completion(.doNotRetry)
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        let loginController = LoginController()
                        window.rootViewController = UINavigationController(rootViewController: loginController)
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
}
