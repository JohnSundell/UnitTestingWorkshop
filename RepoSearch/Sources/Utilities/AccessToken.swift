import Foundation

struct AccessToken {
    static let token: String = {
        let arguments = CommandLine.arguments

        guard arguments.count > 1 else {
            return ""
        }

        return arguments[1]
    }()
}
