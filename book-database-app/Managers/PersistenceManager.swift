import Foundation

enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favorites = "favorites"
    }
    
    static func updateWith(favorite: Book, actionType: PersistenceActionType, completed: @escaping (ErrorMessage?) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(let favorites):
                
                var retrievedFavorites = favorites
                
                switch actionType {
                case .add:
                    guard !retrievedFavorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    retrievedFavorites.append(favorite)
                case .remove:
                    retrievedFavorites.removeAll { $0.id == favorite.id }
                }
                
                completed(save(favorites: retrievedFavorites))
            case .failure(let err):
                completed(err)
            }
        }
    }
    
    static func retrieveFavorites(completed: @escaping (Result<[Book], ErrorMessage>) -> Void) {
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Book].self, from: favoritesData)
            
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    static func save(favorites: [Book]) -> ErrorMessage? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.setValue(encodedFavorites, forKey: Keys.favorites)
            
            return nil
        } catch {
            return .unableToFavorite
        }
    }
    
    static func isFavorite(book: Book, completed: @escaping (Result<Bool, ErrorMessage>) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(let favorites):
                completed(.success(favorites.contains(where: { $0.id == book.id })))
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
}
