import Foundation

struct Book: Codable, Hashable {
    var id: String
    var title: String
    var author: String
    var image: String
    var publisher: String
    var published: String
    var isbn13: String
    var isbn10: String
}
