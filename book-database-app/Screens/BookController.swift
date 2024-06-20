import UIKit

final class BookController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bookImageView = BookCoverImageView(frame: .zero)
    var tableView = UITableView()
    
    var book: Book?
    var bookInformations: [[String]] = []
    
    var isFavorite: Bool = false {
        didSet {
            updateFavoriteButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        configureUI()
        checkIfFavorite()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func configureViewController() {
        title = "Book View"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .done, target: self, action: #selector(addFavoriteButtonTapped))
        navigationItem.rightBarButtonItem = favoriteButton
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }
    
    func updateFavoriteButton() {
        let buttonImageName = isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: buttonImageName)
    }
    
    func checkIfFavorite() {
        guard let favorite = self.book else { return }
        
        PersistenceManager.isFavorite(book: favorite) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isFavorite):
                self.isFavorite = isFavorite
            case .failure(let error):
                self.presentAlertOnMainThread(title: "Error", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    @objc func addFavoriteButtonTapped() {
        guard let favorite = self.book else { return }
        
        let actionType: PersistenceActionType = isFavorite ? .remove : .add
        
        PersistenceManager.updateWith(favorite: favorite, actionType: actionType) { [weak self] err in
            guard let self = self else { return }
            guard let err = err else {
                self.isFavorite.toggle()
                NotificationCenter.default.post(name: NSNotification.Name("FavoritesUpdated"), object: nil)
                return
            }
            self.presentAlertOnMainThread(title: "Error", message: err.rawValue, buttonTitle: "Ok")
        }
    }
    
    func configureUI() {
        guard let book = book else { return }
        
        view.addSubview(bookImageView)
        view.addSubview(tableView)
        
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            bookImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            bookImageView.heightAnchor.constraint(equalToConstant: 300),
            bookImageView.widthAnchor.constraint(equalToConstant: 200),
            
            tableView.topAnchor.constraint(equalTo: bookImageView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        bookInformations.append(contentsOf: [
            ["Title", book.title],
            ["Author", book.author],
            ["Publisher", book.publisher],
            ["ISBN-10", book.isbn10],
            ["ISBN-13", book.isbn13],
            ["Published", book.published]
        ])
        
        bookImageView.downloadImage(from: book.image)
    }
}

extension BookController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Information"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookInformations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = bookInformations[indexPath.row][1]
        cell.detailTextLabel?.text = bookInformations[indexPath.row][0]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}
