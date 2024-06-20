import SwiftUI
import UIKit

final class SearchController: UIViewController {
    
    let logoImageView = UIImageView()
    let searchTextField = SearchTextField()
    let searchButton = ActionButton(backgroundColor: .systemRed, title: "Search")
    
    var isIsbnEntered: Bool {
        return !searchTextField.text!.isEmpty
    }
    
    let containerView = UIView()
    var containerViewCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureUI()
        createDismissKeyboardTapGesture()
        configureKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemRed
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(tappedLogout))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func tappedLogout() {
        AuthManager.shared.signOut { success in
            if success {
                DispatchQueue.main.async {
                    let loginController = LoginController()
                    UIView.transition(with: self.view.window!,
                                      duration: 0.5,
                                      options: .transitionCurlDown,
                                      animations: {
                        self.view.window?.rootViewController = loginController
                    }) { _ in
                        self.view.window?.makeKeyAndVisible()
                    }
                }
            } else {
                print("Sign out failed")
            }
        }
    }
    
    @objc func searchBook() {
        
        guard isIsbnEntered else {
            presentAlertOnMainThread(title: "Input Error", message: "Please enter a valid ISBN number to proceed with your search.", buttonTitle: "Ok")
            return
        }
        
        guard let isbn = searchTextField.text else { return }
        let url = "http://localhost:3000/api/books/search/\(isbn)"
        
        APIService.shared.request(url, method: .get, parameters: nil, responseType: Book.self) { result in
            switch result {
            case .success(let book):
                DispatchQueue.main.async {
                    let bookController = BookController()
                    bookController.book = book
                    self.navigationController?.pushViewController(bookController, animated: true)
                }
            case .failure(let error):
                self.presentAlertOnMainThread(title: "Something Wrong", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }
    
    func configureUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(logoImageView)
        containerView.addSubview(searchTextField)
        containerView.addSubview(searchButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let logoImage = UIImage(named: "Logo") {
            logoImageView.image = logoImage
        } else {
            logoImageView.image = nil
            logoImageView.backgroundColor = .gray
        }
        
        logoImageView.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            
            searchTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 25),
            searchTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 50),
            
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            searchButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            searchButton.heightAnchor.constraint(equalToConstant: 50),
            searchButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        containerViewCenterYConstraint = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerViewCenterYConstraint,
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        searchTextField.delegate = self
        searchButton.addTarget(self, action: #selector(searchBook), for: .touchUpInside)
    }
}

extension SearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBook()
        return true
    }
}

extension SearchController {
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func configureKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        containerViewCenterYConstraint.constant = -keyboardHeight / 2
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        containerViewCenterYConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
