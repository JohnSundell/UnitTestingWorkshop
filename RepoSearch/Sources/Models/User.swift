import Foundation

struct User: Codable {
    let id: Int
    let login: String
    let name: String?
    let bio: String?
}
