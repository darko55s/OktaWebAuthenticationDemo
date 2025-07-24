import Foundation
import BrowserSignin

struct TokenInfo {
    var idToken: String
    var tokenIssuer: String
    var preferredUsername: String
    var authTime: String?
    var issuedAt: String?
    
    init(idToken: JWT) {
        self.idToken = idToken.rawValue
        self.tokenIssuer = idToken.issuer ?? "No Issuer found"
        self.preferredUsername = idToken.preferredUsername ?? "No preferred_username found"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        if let authTime = idToken.authTime {
            self.authTime = formatter.string(from: authTime)
        }
        
        if let issuedAt = idToken.issuedAt {
            self.issuedAt = formatter.string(from: issuedAt)
        }
    }
    
    func toString() -> String {
        var result = ""
     
        result.append("ID Token: \(idToken)")
        result.append("\n")
        result.append("Preffered username: \(preferredUsername)")
        result.append("\n")
        result.append("Token Issuer: \(tokenIssuer)")
        result.append("\n")
        if let authTime {
            result.append("Auth time: \(authTime)")
            result.append("\n")
        }
        
        if let issuedAt {
            result.append("Issued at: \(issuedAt)")
            result.append("\n")
        }

        return result
    }
}
