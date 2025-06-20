import UIKit
import WebAuthenticationUI

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var idToken: String? { get }
    
    func tokenInfo() -> [String: String]
    func userInfo() async throws -> [String: String]

    func signIn(from window: UIWindow?) async throws
    func signOut(from window: UIWindow?) async throws
    func refreshTokenIfNeeded() async throws
}

final class AuthService: AuthServiceProtocol {
    
    var isAuthenticated: Bool {
        return Credential.default != nil
    }
    
    var idToken: String? {
        return Credential.default?.token.idToken?.rawValue
    }
    
    func signIn(from window: UIWindow?) async throws {
        WebAuthentication.shared?.ephemeralSession = true
        let tokens = try await WebAuthentication.shared?.signIn(from: window)
        if let tokens {
            _ = try? Credential.store(tokens)
        }
    }
    
    func signOut(from window: UIWindow?) async throws {
        guard let credential = Credential.default else { return }
        try await WebAuthentication.shared?.signOut(from: window, token: credential.token)
        try? credential.remove()
    }
    
    func refreshTokenIfNeeded() async throws {
        guard let credential = Credential.default else { return }
        try await credential.refresh()
    }
}

extension AuthService {
    func tokenInfo() -> [String: String] {
        guard let idToken = Credential.default?.token.idToken else {
            return ["Status": "No token available"]
        }
        
        var info: [String: String] = [
            "ID Token": idToken.rawValue,
            "Token Issuer": idToken.issuer ?? "No Issuer",
            "Preferred Username": idToken.preferredUsername ?? "No preferred_username"
        ]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        if let authTime = idToken.authTime {
            info["Auth time"] = formatter.string(from: authTime)
        }
        
        if let issuedAt = idToken.issuedAt {
            info["Issued at"] = formatter.string(from: issuedAt)
        }
        
        return info
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


