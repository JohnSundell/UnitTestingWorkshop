import UIKit

final class LoadingViewController: UIViewController {
    private lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(activityIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        activityIndicator.sizeToFit()
        activityIndicator.center.x = view.bounds.width / 2
        activityIndicator.center.y = view.bounds.height / 2
    }
}
