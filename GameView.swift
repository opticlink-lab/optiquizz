//
//  GameView.swift
//  optiquizz
//
//  Vue principale du jeu avec les questions
//

import SwiftUI

struct GameView: View {
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
            // Fond dégradé
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let question = currentQuestion {
                VStack(spacing: 0) {
                    // En-tête avec score et progression
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
                    
                    // Barre de progression
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 6)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Difficulté
                            HStack {
                                Spacer()
                                Text(question.difficulty.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(
                                        question.difficulty == .facile ? Color.green :
                                        question.difficulty == .moyen ? Color.orange :
                                        Color.red
                                    )
                                    .cornerRadius(20)
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
                        }
                    }
                    
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
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
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
            } else {
                // Écran de chargement ou fin
                ProgressView()
                    .scaleEffect(2)
                    .tint(.white)
            }
        }
        .onAppear {
            startGame()
        }
        .onChange(of: currentQuestionIndex) { oldValue, newValue in
            shuffleAnswersForCurrentQuestion()
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                score: score,
                totalQuestions: questions.count,
                maxScore: questions.reduce(0) { $0 + $1.difficulty.points }
            )
        }
    }
    
    private func startGame() {
        // Mélanger les questions et en prendre 10
        questions = QuizData.questions.shuffled().prefix(10).map { $0 }
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
            score += currentQuestion?.difficulty.points ?? 0
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

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.8)
        } else if isWrong {
            return Color.red.opacity(0.8)
        } else if isSelected {
            return Color.white.opacity(0.3)
        } else {
            return Color.white.opacity(0.2)
        }
    }
    
    private var strokeColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color.white.opacity(0.5)
        } else {
            return Color.white.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        return (isSelected || isCorrect || isWrong) ? 2 : 1
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                } else if isSelected {
                    Image(systemName: "circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
        }
        .disabled(isDisabled)
    }
}

#Preview {
    GameView()
}

