//
//  PremiumAccessManager.swift
//  optiquizz
//
//  Gestion de l'accès payant aux modules ETSO et Analyse de la vision.
//  Déblocage par code personnel envoyé après virement (RIB).
//

import Foundation

/// Gestionnaire d'accès premium : virement sur RIB puis code personnel reçu par SMS/email.
final class PremiumAccessManager: ObservableObject {
    static let shared = PremiumAccessManager()
    
    private let defaults = UserDefaults.standard
    private let hasAccessKey = "premium_has_access"
    
    /// Codes de déblocage personnels envoyés à chaque utilisateur après réception du virement.
    /// Ajoutez ici chaque nouveau code que vous envoyez (mise à jour de l'app à chaque ajout, sauf backend).
    private let validUnlockCodes: Set<String> = [
        "OPTIC2025"  // Exemple ; ajoutez les codes personnels au fur et à mesure.
    ]
    
    @Published private(set) var hasAccess: Bool {
        didSet { defaults.set(hasAccess, forKey: hasAccessKey) }
    }
    
    private init() {
        self.hasAccess = defaults.bool(forKey: hasAccessKey)
    }
    
    /// Débloque l'accès si le code saisi est valide (code personnel reçu après virement).
    func unlock(withCode code: String) -> Bool {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard validUnlockCodes.contains(normalized) else { return false }
        hasAccess = true
        return true
    }
    
    /// Révoque l'accès (utile pour tests).
    func revokeAccess() {
        hasAccess = false
    }
}
