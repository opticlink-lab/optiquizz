//
//  PaywallView.swift
//  optiquizz
//
//  Écran paywall : paiement par virement (RIB) puis code personnel reçu par SMS/email.
//

import SwiftUI

/// RIB affiché à l'utilisateur pour le virement. Remplacez par vos coordonnées bancaires réelles.
private let paywallRIB = """
REMPLACER_PAR_VOTRE_IBAN
Titulaire : Votre nom
BIC : VOTRE_BIC
"""

struct PaywallView: View {
    @ObservedObject private var access = PremiumAccessManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var unlockCode = ""
    @State private var codeError: String?
    @State private var ribCopied = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.9), Color.red.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                    
                    Text("Accès premium")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Débloquez les modules ETSO (Retracer les rayons) et Analyse de la vision pour accéder à tout le contenu BTS Opticien-Lunetier.")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Instructions virement
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Paiement par virement")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Indiquez votre numéro de téléphone dans la communication du virement pour recevoir un code personnel par SMS ou email et débloquer l'accès.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.95))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(paywallRIB)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        
                        Button(action: copyRIB) {
                            HStack {
                                Image(systemName: ribCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                Text(ribCopied ? "Copié !" : "Copier le RIB")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .background(Color.white.opacity(0.6))
                        .padding(.horizontal, 40)
                    
                    // Saisie du code
                    VStack(spacing: 10) {
                        Text("Déjà effectué ? Entrez votre code personnel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            TextField("Code reçu par SMS ou email", text: $unlockCode)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .frame(maxWidth: .infinity)
                            
                            Button(action: tryUnlock) {
                                Text("Débloquer")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.25))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        if let err = codeError {
                            Text(err)
                                .font(.system(size: 13))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer(minLength: 24)
                    
                    Button(action: { dismiss() }) {
                        Text("Retour à l'accueil")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.bottom, 32)
                }
                .padding(.top, 28)
            }
        }
        .onChange(of: access.hasAccess) { _, hasAccess in
            if hasAccess { dismiss() }
        }
    }
    
    private func copyRIB() {
        #if canImport(UIKit)
        UIPasteboard.general.string = paywallRIB
        ribCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { ribCopied = false }
        #endif
    }
    
    private func tryUnlock() {
        codeError = nil
        if access.unlock(withCode: unlockCode) {
            // hasAccess = true → onChange appelle dismiss()
        } else {
            codeError = "Code incorrect. Vérifiez le code reçu par SMS ou email."
        }
    }
}

#Preview {
    PaywallView()
}
