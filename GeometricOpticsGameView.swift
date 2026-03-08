//
//  GeometricOpticsGameView.swift
//  optiquizz
//
//  Vue du quiz "Optique géométrique"
//

import SwiftUI

struct GeometricOpticsGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var score = 0
    @State private var showResult = false
    @State private var isAnswered = false
    @State private var showCorrectAnswer = false
    @State private var shuffledAnswers: [String] = []
    @State private var correctAnswerIndex: Int = 0
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            // Fond dégradé (couleur différente pour différencier)
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.9), Color.cyan.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showResult {
                ResultView(
                    score: score,
                    totalQuestions: questions.count,
                    maxScore: questions.reduce(0) { $0 + $1.difficulty.points }
                )
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    // En-tête
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(score)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Question")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(currentQuestionIndex + 1)/\(questions.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Contenu
                    ScrollView {
                        VStack(spacing: 20) {
                            // Difficulté
                            HStack {
                                Spacer()
                                Text(question.difficulty.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(question.difficulty == .facile ? Color.green.opacity(0.7) :
                                                  question.difficulty == .moyen ? Color.orange.opacity(0.7) :
                                                  Color.red.opacity(0.7))
                                    )
                                Spacer()
                            }
                            .padding(.top, 30)
                            
                            // Question
                            Text(question.text)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.2))
                                )
                                .padding(.horizontal, 20)
                            
                            // Réponses
                            VStack(spacing: 15) {
                                ForEach(0..<shuffledAnswers.count, id: \.self) { index in
                                    AnswerButton(
                                        text: shuffledAnswers[index],
                                        isSelected: selectedAnswerIndex == index,
                                        isCorrect: index == correctAnswerIndex && showCorrectAnswer,
                                        isWrong: selectedAnswerIndex == index && index != correctAnswerIndex && showCorrectAnswer,
                                        isDisabled: isAnswered
                                    ) {
                                        if !isAnswered {
                                            selectAnswer(index)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            
                            // Bouton suivant
                            if isAnswered {
                                Button(action: {
                                    nextQuestion()
                                }) {
                                    HStack {
                                        Text(currentQuestionIndex + 1 < questions.count ? "Question suivante" : "Voir les résultats")
                                            .font(.system(size: 20, weight: .bold))
                                        Image(systemName: "arrow.right")
                                            .font(.title3)
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
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            startGame()
        }
    }
    
    private func startGame() {
        // Mélanger les questions et en prendre 10
        questions = GeometricOpticsQuizData.questions.shuffled().prefix(10).map { $0 }
        currentQuestionIndex = 0
        score = 0
        selectedAnswerIndex = nil
        isAnswered = false
        showCorrectAnswer = false
        shuffleAnswersForCurrentQuestion()
    }
    
    private func shuffleAnswersForCurrentQuestion() {
        guard let question = currentQuestion else { return }
        
        // Créer un tableau d'indices pour mélanger
        var indices = Array(0..<question.answers.count)
        indices.shuffle()
        
        // Mélanger les réponses
        shuffledAnswers = indices.map { question.answers[$0] }
        
        // Trouver le nouvel index de la bonne réponse
        if let originalCorrectIndex = indices.firstIndex(of: question.correctAnswerIndex) {
            correctAnswerIndex = originalCorrectIndex
        } else {
            correctAnswerIndex = 0
        }
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswerIndex = index
        isAnswered = true
        showCorrectAnswer = true
        
        // Vérifier si la réponse est correcte
        if index == correctAnswerIndex {
            if let question = currentQuestion {
                score += question.difficulty.points
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            isAnswered = false
            showCorrectAnswer = false
            shuffleAnswersForCurrentQuestion()
        } else {
            showResult = true
        }
    }
}



