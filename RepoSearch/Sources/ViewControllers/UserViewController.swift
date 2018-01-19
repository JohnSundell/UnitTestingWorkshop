import UIKit

final class UserViewController: UITableViewController {
    private let cellReuseIdentifier = "cell"
    private let username: String
    private var user: User?
    private var repositories = [Repository]()
    private var loadingViewController: LoadingViewController?
    private var errorViewController: ErrorViewController?

    // MARK: - Initializers

    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
        title = username
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUser()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repositories"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = repositories[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = repository.name
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let repositoryVC = RepositoryViewController(repository: repository)
        navigationController?.pushViewController(repositoryVC, animated: true)
    }

    // MARK: - Private

    private func loadUser() {
        errorViewController?.remove()
        errorViewController = nil

        loadingViewController?.remove()
        loadingViewController = nil

        let cacheKey = "user-\(username)"

        if let cachedData = Cache.shared.data(forKey: cacheKey) {
            let decoder = JSONDecoder()

            if let user = try? decoder.decode(User.self, from: cachedData) {
                didLoadUser(user)
                return
            }
        }

        let loadingVC = LoadingViewController()
        add(loadingVC)
        loadingViewController = loadingVC

        let url = URL(string: "https://api.github.com/users/\(username)?access_token=\(AccessToken.token)")!

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handle(error)
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let user = try decoder.decode(User.self, from: data)

                        Cache.shared.cache(data, forKey: cacheKey)
                        self?.didLoadUser(user)
                    } catch {
                        self?.handle(error)
                    }
                } else {
                    self?.handle(MissingDataError())
                }
            }
        }

        task.resume()
    }

    private func handle(_ error: Error) {
        loadingViewController?.remove()
        loadingViewController = nil

        let errorVC = ErrorViewController()
        errorViewController = errorVC

        errorVC.render(error)
        add(errorVC)

        errorVC.reloadHandler = { [weak self] in
            self?.loadUser()
        }
    }

    private func didLoadUser(_ user: User) {
        self.user = user
        title = user.name ?? title
        tableView.reloadData()

        let bioLabel = UILabel()
        bioLabel.numberOfLines = 0
        bioLabel.text = user.bio
        bioLabel.frame.origin.x = 20
        bioLabel.frame.origin.y = bioLabel.frame.minX
        bioLabel.frame.size.width = view.bounds.width - bioLabel.frame.minX * 2
        bioLabel.sizeToFit()

        let headerView = UIView()
        headerView.frame.size.width = view.bounds.width
        headerView.frame.size.height = bioLabel.frame.maxY + bioLabel.frame.minY
        headerView.addSubview(bioLabel)
        tableView.tableHeaderView = headerView

        loadRepositories()
    }

    private func loadRepositories() {
        let cacheKey = "repositories-\(username)"

        if let cachedData = Cache.shared.data(forKey: cacheKey) {
            let decoder = JSONDecoder()

            if let repositories = try? decoder.decode([Repository].self, from: cachedData) {
                didLoadRepositories(repositories)
                return
            }
        }

        let url = URL(string: "https://api.github.com/users/\(username)/repos?access_token=\(AccessToken.token)")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handle(error)
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let repositories = try decoder.decode([Repository].self, from: data)

                        Cache.shared.cache(data, forKey: cacheKey)
                        self?.didLoadRepositories(repositories)
                    } catch {
                        self?.handle(error)
                    }
                } else {
                    self?.handle(MissingDataError())
                }
            }
        }

        task.resume()
    }

    private func didLoadRepositories(_ repositories: [Repository]) {
        self.repositories = repositories
        tableView.reloadData()
        loadingViewController?.remove()
        loadingViewController = nil
    }
}

private extension UserViewController {
    struct MissingDataError: Error {}
}
