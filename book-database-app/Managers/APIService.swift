import UIKit
import Alamofire

class APIService {
    static let shared = APIService()
    
    private let session: Session
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        let interceptor = AuthInterceptor()
        self.session = Session(interceptor: interceptor)
    }
    
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, responseType: T.Type, completion: @escaping (Result<T, AFError>) -> Void) {
        session.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default).validate().responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                    print("Response data: \(json)")
                }
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        session.request(urlString).validate().responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: cacheKey)
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}
