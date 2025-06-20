import UIKit

class UserInfoViewController: UIViewController {
    private let data: [String: String]

    init(data: [String: String]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "User Info"

        let textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 14, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = data.map { "\($0): \($1)" }.sorted().joined(separator: "\n")

        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
