import Foundation

final class Cache {
    static let shared = Cache()

    private var inMemoryData = NSCache<NSString, NSData>()

    func data(forKey key: String) -> Data? {
        if let data = inMemoryData.object(forKey: key as NSString) {
            return data as Data
        }

        let url = fileURL(forKey: key)
        return try? Data(contentsOf: url)
    }

    func cache(_ data: Data, forKey key: String) {
        inMemoryData.setObject(data as NSData, forKey: key as NSString)

        let url = fileURL(forKey: key)
        try? data.write(to: url)
    }

    private func fileURL(forKey key: String) -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
        return directoryURL.appendingPathComponent("cache-\(key)")
    }
}
