import Foundation

struct Repository: Codable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let owner: Owner
}

extension Repository {
    struct Owner: Codable {
        let id: Int
        let login: String
        let type: Kind?
    }
}

extension Repository.Owner {
    enum Kind: String, Codable {
        case user = "User"
        case organization = "Organization"
    }
}
