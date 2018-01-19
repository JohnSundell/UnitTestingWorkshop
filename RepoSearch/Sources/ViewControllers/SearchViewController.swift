import UIKit

final class SearchViewController: UITableViewController, UISearchResultsUpdating {
    private let cellReuseIdentifier = "cell"
    private let searchController = UISearchController(searchResultsController: nil)
    private var errorViewController: ErrorViewController?
    private var result = SearchResult()
    private var pendingTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search GitHub Repositories"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let backItem = UIBarButtonItem()
        backItem.title = "Seach"
        navigationItem.backBarButtonItem = backItem

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        loadSearchResults()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = result.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = repository.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = result.items[indexPath.row]
        let repositoryVC = RepositoryViewController(repository: repository)
        navigationController?.pushViewController(repositoryVC, animated: true)
    }

    // MARK: - Private

    private func loadSearchResults() {
        pendingTask?.cancel()
        pendingTask = nil

        guard let query = searchController.searchBar.text else {
            return
        }

        let url = URL(string: "https://api.github.com/search/repositories?q=\(query)&access_token=\(AccessToken.token)")!

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.errorViewController?.remove()
                self?.errorViewController = nil

                if let error = error {
                    if (error as NSError).code != URLError.cancelled.rawValue {
                        self?.handle(error)
                    }
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        self?.result = try decoder.decode(SearchResult.self, from: data)
                        self?.tableView.reloadData()
                    } catch {
                        self?.handle(error)
                    }
                } else {
                    self?.handle(MissingDataError())
                }
            }
        }

        pendingTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            task.resume()
        }
    }

    private func handle(_ error: Error) {
        let errorVC = ErrorViewController()
        errorViewController = errorVC

        errorVC.render(error)
        add(errorVC)

        errorVC.reloadHandler = { [weak self] in
            self?.loadSearchResults()
        }
    }
}

private extension SearchViewController {
    struct MissingDataError: Error {}
}
