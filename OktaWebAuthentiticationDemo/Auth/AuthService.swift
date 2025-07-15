import UIKit
import BrowserSignin

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var idToken: String? { get }
    
    func tokenInfo() -> TokenInfo?
    func userInfo() async throws -> [String: String]

    func signIn(from window: UIWindow?) async throws
    func signOut(from window: UIWindow?) async throws
    func refreshTokenIfNeeded() async throws
    
    func fetchMessageFromBackend() async -> String
}

final class AuthService: AuthServiceProtocol {
    
    var isAuthenticated: Bool {
        return Credential.default != nil
    }
    
    var idToken: String? {
        return Credential.default?.token.accessToken
    }
    
    @MainActor
    func signIn(from window: UIWindow?) async throws {
        BrowserSignin.shared?.ephemeralSession = true
        let tokens = try await BrowserSignin.shared?.signIn(from: window)
        if let tokens {
            _ = try? Credential.store(tokens)
        }
    }
    
    @MainActor
    func signOut(from window: UIWindow?) async throws {
        guard let credential = Credential.default else { return }
        try await BrowserSignin.shared?.signOut(from: window, token: credential.token)
        try? credential.remove()
    }
    
    func refreshTokenIfNeeded() async throws {
        guard let credential = Credential.default else { return }
        try await credential.refresh()
    }
    
    @MainActor
    func fetchMessageFromBackend() async -> String {
        guard let credential = Credential.default else {
            return "Not authenticated."
        }

        var request = URLRequest(url: URL(string: "http://localhost:8000/api/messages")!)
        request.httpMethod = "GET"

        await credential.authorize(&request)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let response = try decoder.decode(MessageResponse.self, from: data)
            if let randomMessage = response.messages.randomElement() {
                return "\(randomMessage.text)"
            } else {
                return "No messages found."
            }
        } catch {
            return "Error fetching message: \(error.localizedDescription)"
        }
    }
}

extension AuthService {
    func tokenInfo() -> TokenInfo? {
        guard let idToken = Credential.default?.token.idToken else {
            return nil
        }
        
        return TokenInfo(idToken: idToken)
    }
}

extension AuthService {
    func userInfo() async -> [String: String] {

        if let userInfo = Credential.default?.userInfo {
            return parseUserInfo(userInfo)
        } else {
            do {
                guard let userInfo = try await Credential.default?.userInfo() else {
                    return ["Unable to Show User Info": "Could not info for the current user."]
                }
                return parseUserInfo(userInfo)
            } catch {
                return ["Unable to Show User Info": "Could not info for the current user."]
            }
           
        }
    }
    
    func parseUserInfo(_ userInfo: UserInfo) -> [String: String] {
        var info: [String: String] = [:]

        info["Name"] = userInfo.name
        info["Username"] = userInfo.preferredUsername
        
        if let updatedAt = userInfo.updatedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            info["Updated at"] = dateFormatter.string(for: updatedAt)
        } else {
            info["Updated at"] = "N/A"
        }
        return info
    }
}


