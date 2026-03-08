//
//  HomeView.swift
//  optiquizz
//
//  Vue d'accueil du jeu
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var premium = PremiumAccessManager.shared
    @State private var showGame = false
    @State private var showETSO = false
    @State private var showVisionAnalysis = false
    @State private var showGeometricOptics = false
    @State private var showSemantix = false
    @State private var showPaywall = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Fond dégradé
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Lien discret vers le mode "Semantix optique"
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showSemantix = true
                    }) {
                        Text("Semantix optique")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Titre
                VStack(spacing: 10) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Champion")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("OPTIQUIZZ")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
                
                Spacer()
                
                // Boutons de navigation
                VStack(spacing: 15) {
                    // Bouton PDM (Questions)
                    Button(action: {
                        showGame = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                            Text("PDM - Questions")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Bouton ETSO - Schémas interactifs (payant)
                    Button(action: {
                        if premium.hasAccess { showETSO = true }
                        else { showPaywall = true }
                    }) {
                        HStack {
                            Image(systemName: "pencil.and.outline")
                                .font(.title2)
                            Text("ETSO - Retracer les Rayons")
                                .font(.system(size: 20, weight: .bold))
                            if !premium.hasAccess {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Bouton Analyse de la vision (payant)
                    Button(action: {
                        if premium.hasAccess { showVisionAnalysis = true }
                        else { showPaywall = true }
                    }) {
                        HStack {
                            Image(systemName: "eye.trianglebadge.exclamationmark")
                                .font(.title2)
                            Text("Analyse de la vision")
                                .font(.system(size: 20, weight: .bold))
                            if !premium.hasAccess {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.pink.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Bouton Optique géométrique
                    Button(action: {
                        showGeometricOptics = true
                    }) {
                        HStack {
                            Image(systemName: "circle.grid.hex")
                                .font(.title2)
                            Text("Optique géométrique")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.teal, Color.cyan.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Répondez aux questions sur l'optique")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Gagnez des points selon la difficulté")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView()
        }
        .fullScreenCover(isPresented: $showETSO) {
            ETSOHybridView()
        }
        .fullScreenCover(isPresented: $showSemantix) {
            OpticSemantixView()
        }
        .fullScreenCover(isPresented: $showVisionAnalysis) {
            VisionAnalysisGameView()
        }
        .fullScreenCover(isPresented: $showGeometricOptics) {
            GeometricOpticsGameView()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    HomeView()
}

