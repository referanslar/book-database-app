import Foundation

struct ErrorResponse: Decodable {
    let result: ErrorResult
}

struct ErrorResult: Decodable {
    let message: String
    let errors: [FieldError]?
}

struct FieldError: Decodable {
    let type: String
    let value: String
    let msg: String
    let path: String
    let location: String
}

enum ErrorMessage: String, Error {
    case unableToFavorite = "An error occurred while trying to favorite this book. Please try again."
    case alreadyInFavorites = "This book is already in your favorites."
}
