//
//  ResultView.swift
//  optiquizz
//
//  Vue des résultats finaux
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let totalQuestions: Int
    let maxScore: Int
    @Environment(\.dismiss) var dismiss
    @State private var showHome = false
    
    var percentage: Int {
        guard maxScore > 0 else { return 0 }
        return Int((Double(score) / Double(maxScore)) * 100)
    }
    
    var rating: String {
        switch percentage {
        case 80...100:
            return "Excellent !"
        case 60..<80:
            return "Très bien !"
        case 40..<60:
            return "Bien !"
        default:
            return "Continuez !"
        }
    }
    
    var emoji: String {
        switch percentage {
        case 80...100:
            return "🏆"
        case 60..<80:
            return "⭐"
        case 40..<60:
            return "👍"
        default:
            return "💪"
        }
    }
    
    var body: some View {
        ZStack {
            // Fond dégradé
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Emoji et titre
                Text(emoji)
                    .font(.system(size: 100))
                
                Text(rating)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                // Score
                VStack(spacing: 15) {
                    Text("Votre score")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(score) / \(maxScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("\(percentage)%")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                )
                .padding(.horizontal, 30)
                
                // Statistiques
                VStack(spacing: 15) {
                    HStack {
                        Text("Questions répondues:")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(totalQuestions)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Score total:")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(score) points")
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
                .font(.system(size: 18))
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Boutons
                VStack(spacing: 15) {
                    Button(action: {
                        showHome = true
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Menu principal")
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
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Rejouer")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showHome) {
            HomeView()
        }
    }
}

#Preview {
    ResultView(score: 15, totalQuestions: 10, maxScore: 20)
}

