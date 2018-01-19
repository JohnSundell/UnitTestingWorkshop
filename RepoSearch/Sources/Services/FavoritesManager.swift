import Foundation

final class FavoritesManager {
    static let shared = FavoritesManager()

    private let defaultsKey = "favorites"
    private var favoriteIDs: Set<Int>

    private init() {
        let array = UserDefaults.standard.array(forKey: defaultsKey) as? [Int]
        favoriteIDs = array.map(Set.init) ?? []
    }

    func isRepositoryInFavorites(_ repository: Repository) -> Bool {
        return favoriteIDs.contains(repository.id)
    }

    func addRepositoryToFavorites(_ repository: Repository) {
        favoriteIDs.insert(repository.id)
        try? saveToUserDefaults()
    }

    func removeRepositoryFromFavorites(_ repository: Repository) {
        favoriteIDs.remove(repository.id)
        try? saveToUserDefaults()
    }

    private func saveToUserDefaults() throws {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: defaultsKey)
    }
}
