import UIKit

class LoginController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = BDAuthHeaderView(title: "Sign In", subTitle: "Sign in to book database.")
    
    private let emailField = BDAuthTextField(fieldType: .email)
    private let passwordField = BDAuthTextField(fieldType: .password)
    
    private let signInButton = BDButton(title: "Sign In", hasBackground: true, fontSize: .big)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(headerView)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signInButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 10),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: 55),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            self.signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signInButton.heightAnchor.constraint(equalToConstant: 55),
            self.signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
        
        self.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    @objc private func didTapSignIn() {
        guard let email = emailField.text, let password = passwordField.text else {
            print("Email ve şifre alanları boş olamaz")
            return
        }
        
        AuthManager.shared.login(email: email, password: password) { success, errorResponse in
            if success {
                DispatchQueue.main.async {
                    let mainTabController = MainTabController()
                    UIView.transition(with: self.view.window!,
                                      duration: 0.5,
                                      options: .transitionCurlUp,
                                      animations: {
                        self.view.window?.rootViewController = mainTabController
                    }) { _ in
                        self.view.window?.makeKeyAndVisible()
                    }
                }
            } else {
                print("Sign in fail.")
                if let errorResponse = errorResponse {
                    print("Message: \(errorResponse.result.message)")
                    if let errors = errorResponse.result.errors {
                        for error in errors {
                            print("Error: \(error.msg) in \(error.path)")
                        }
                    }
                }
            }
        }
    }
}
