import UIKit

func activate(_ constraints: NSLayoutConstraint...) {
    constraints.forEach { $0.isActive = true }
}
