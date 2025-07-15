import SwiftUI

@Observable
class ContentViewModel {
    let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
}

struct ContentView: View {
    @Environment(ContentViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.authService.isAuthenticated,
               let tokenInfo = viewModel.authService.tokenInfo() {
                // Display user info from token
                Text("Hello, \(tokenInfo.preferredUsername)!")
                    .font(.headline)
                Text("ID Token: \(tokenInfo.idToken)")
                    .font(.caption)

                Button("Logout") {
                    Task {
                        try? await viewModel.authService.signOut(from: nil)
                    }
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.red)

            } else {
                Button("Login with Okta") {
                    Task {
                        try? await viewModel.authService.signIn(from: nil)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
