import UIKit

class TokenInfoViewController: UIViewController {

    private let tokenData: [String: String]

    init(tokenData: [String: String]) {
        self.tokenData = tokenData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(tokenData:) instead")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Token Info"

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)

        textView.text = tokenData
            .map { "\($0): \($1)" }
            .sorted()
            .joined(separator: "\n")

        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
