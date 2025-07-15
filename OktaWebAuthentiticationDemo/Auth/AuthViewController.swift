import UIKit
import BrowserSignin

class AuthViewController: UIViewController {
    private let statusLabel = UILabel()
    private let tokenLabel = UILabel()
    private let authButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄 Refresh Token", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let userInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👤 User Info", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎁 Get Message", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let authService: AuthServiceProtocol

    // MARK: - Init
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Will appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("will dissapear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        authButton.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        userInfoButton.addTarget(self, action: #selector(userInfoTapped), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(fetchMessageTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 24, weight: .medium)
        
        tokenLabel.font = .systemFont(ofSize: 12)
        tokenLabel.numberOfLines = 0
        tokenLabel.textAlignment = .center
        
        authButton.setTitle("Sign In", for: .normal)
        authButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        authButton.configuration = .filled()
        
        activityIndicator.hidesWhenStopped = true

        let stack = UIStackView(arrangedSubviews: [
            statusLabel,
            tokenLabel,
            authButton,
            refreshButton,
            infoButton,
            userInfoButton,
            messageButton,
            activityIndicator
        ])
        
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateUI() {
        let isAuthenticated = authService.isAuthenticated
        statusLabel.text = isAuthenticated ? "✅ Logged In" : "🔒 Logged Out"
        authButton.setTitle(isAuthenticated ? "Sign Out" : "Sign In", for: .normal)
        tokenLabel.text = authService.idToken.map { "ID Token:\n\($0)" } ?? ""
        
        tokenLabel.isHidden = !isAuthenticated
        refreshButton.isHidden = !isAuthenticated
        userInfoButton.isHidden = !isAuthenticated
        infoButton.isHidden = !isAuthenticated
        
        if let idToken = authService.idToken {
            print("ID Token: \(idToken)")
        }
    }

    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.updateButtons(enabled: !loading)
            loading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
    }
    
    private func updateButtons(enabled: Bool) {
        self.authButton.isEnabled = enabled
        self.refreshButton.isEnabled = enabled
        self.userInfoButton.isEnabled = enabled
        self.infoButton.isEnabled = enabled
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Authentication Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func handleAuthAction() async {
        setLoading(true)
        defer { setLoading(false) }

        do {
            if authService.isAuthenticated {
                try await authService.signOut(from: view.window)
            } else {
                try await authService.signIn(from: view.window)
            }
            updateUI()
        } catch {
            showError(error)
        }
    }

    @objc private func authButtonTapped() {
        Task { await handleAuthAction() }
    }
    
    @objc private func refreshTapped() {
        setLoading(true)
        Task {
            defer { setLoading(false) }
            do {
                try await authService.refreshTokenIfNeeded()
                updateUI()
            } catch {
                showError(error)
            }
        }
    }
    
    @objc private func infoTapped() {
        guard let info = authService.tokenInfo() else { return }
        let vc = TokenInfoViewController(tokenInfo: info)
        present(vc, animated: true)
    }
    
    @objc private func userInfoTapped() {
        Task {
            do {
                let userInfo = try await authService.userInfo()
                let vc = UserInfoViewController(data: userInfo)
                vc.title = "User Info"
                present(vc, animated: true)
            } catch {
                showError(error)
            }
        }
    }
    
    @objc private func fetchMessageTapped() {
        setLoading(true)

        Task {
            defer { setLoading(false) }
            
            let message = await authService.fetchMessageFromBackend()
            showMessage(message)
        }
    }
    
    private func showMessage(_ text: String) {
        let alert = UIAlertController(title: "🎁 Message from Server", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
