import UIKit

final class ErrorViewController: UIViewController {
    var reloadHandler: () -> Void = {}

    private lazy var label = UILabel()
    private lazy var button = UIButton(type: .system)

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .black
        view.addSubview(label)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        view.addSubview(button)

        activate(
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        )
    }

    // MARK: - API

    func render(_ error: Error) {
        label.text = error.localizedDescription
    }

    // MARK: - Private

    @objc private func handleButtonTap() {
        reloadHandler()
    }
}

