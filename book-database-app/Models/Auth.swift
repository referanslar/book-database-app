import Foundation

struct Tokens: Decodable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct LoginResponse: Decodable {
    let id: String
    let name: String?
    let surname: String?
    let email: String
    let tokens: Tokens
}

struct RefreshResponse: Decodable {
    let userID: String
    let tokens: Tokens
}
