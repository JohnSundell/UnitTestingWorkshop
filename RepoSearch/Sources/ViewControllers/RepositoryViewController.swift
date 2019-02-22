import UIKit

final class RepositoryViewController: UITableViewController {
    private let cellReuseIdentifier = "cell"
    private let repository: Repository
    private lazy var cellData = makeCellData()

    // MARK: - Initializers

    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
        title = repository.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.rowHeight = 100
        tableView.register(Cell.self, forCellReuseIdentifier: cellReuseIdentifier)

        updateFavoriteBarButtonItem()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = cellData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! Cell

        cell.textLabel?.text = title(forProperty: data.property)
        cell.accessoryLabel.text = data.text
        cell.accessoryLabel.frame.size.height = tableView.rowHeight
        cell.accessoryLabel.frame.size.width = tableView.bounds.width / 2

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let data = cellData[indexPath.row]
        return isCellSelectable(forProperty: data.property)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = cellData[indexPath.row]

        switch data.property {
        case .description, .language:
            assertionFailure("Should not be able to select cell for property \(data.property)")
        case .owner:
            let userVC = UserViewController(username: repository.owner.login)
            navigationController?.pushViewController(userVC, animated: true)
        }
    }

    // MARK: - Private

    private func makeCellData() -> [(property: Repository.Property, text: String)] {
        return [
            (.description, repository.description ?? ""),
            (.language, repository.language ?? "Unknown"),
            (.owner, repository.owner.login)
        ]
    }

    private func title(forProperty property: Repository.Property) -> String {
        switch property {
        case .description:
            return "Description"
        case .language:
            return "Language"
        case .owner:
            return "Owner"
        }
    }

    private func isCellSelectable(forProperty property: Repository.Property) -> Bool {
        switch property {
        case .description, .language:
            return false
        case .owner:
            return true
        }
    }

    private func updateFavoriteBarButtonItem() {
        let isFavorite = FavoritesManager.shared.isRepositoryInFavorites(repository)
        let itemType = isFavorite ? UIBarButtonItem.SystemItem.trash : .bookmarks

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: itemType,
            target: self,
            action: #selector(toggleFavorite)
        )
    }

    @objc private func toggleFavorite() {
        let manager = FavoritesManager.shared
        let isFavorite = manager.isRepositoryInFavorites(repository)

        if isFavorite {
            manager.removeRepositoryFromFavorites(repository)
        } else {
            manager.addRepositoryToFavorites(repository)
        }

        updateFavoriteBarButtonItem()
    }
}

private extension RepositoryViewController {
    final class Cell: UITableViewCell {
        private(set) lazy var accessoryLabel: UILabel = {
            let label = UILabel()
            label.textColor = .black
            label.numberOfLines = 0
            accessoryView = label
            return label
        }()
    }
}

private extension Repository {
    enum Property {
        case description
        case language
        case owner
    }
}
