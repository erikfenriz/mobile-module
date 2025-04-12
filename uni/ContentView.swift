import SwiftUI

// 📍 Point 1: The Data Model

// Define the structure for a single quiz question
struct Question {
    let text: String                      // The text of the question
    let options: [String]                // Array of answer options
    let correctAnswerIndex: Int         // Index of the correct answer in the options array
}

// 📍 Point 2: The Main View & State Variables

// Main content view that handles quiz display logic
struct ContentView: View {
    
    // List of quiz questions using the Question model
    let questions = [
        Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswerIndex: 2),
        Question(text: "Which planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswerIndex: 1),
        Question(text: "What is the largest ocean on Earth?", options: ["Atlantic Ocean", "Indian Ocean", "Arctic Ocean", "Pacific Ocean"], correctAnswerIndex: 3),
        Question(text: "Who wrote 'Romeo and Juliet'?", options: ["Charles Dickens", "William Shakespeare", "Jane Austen", "Mark Twain"], correctAnswerIndex: 1),
        Question(text: "What is the chemical symbol for gold?", options: ["Go", "Gd", "Au", "Ag"], correctAnswerIndex: 2)
    ]
    
    @State private var selectedAnswers = [Int?](repeating: nil, count: 5)  // Stores the user's selected answers, nil if unanswered
    @State private var showResults = false                                 // Determines whether to show the results view
    @State private var score = 0                                           // Tracks the user's current score
    
    // 📍 Point 3: Body — Switching Between Quiz and Results
    
    var body: some View {
        NavigationView {
            if showResults {
                // Show results when quiz is submitted
                ResultsView(score: score, totalQuestions: questions.count, resetQuiz: resetQuiz)
            } else {
                // Otherwise show the quiz view
                quizView
            }
        }
    }
    
    // 📍 Point 4: The Quiz UI
    
    var quizView: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Quiz Time!")                  // Header for the quiz
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Loop through all questions and show them
                ForEach(0..<questions.count, id: \.self) { index in
                    questionView(for: index)
                }
                
                // Submit button to finish the quiz
                Button(action: checkAnswers) {
                    Text("Submit Answers")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(allQuestionsAnswered ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!allQuestionsAnswered)     // Disable button if any question is unanswered
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationBarTitle("Quiz App", displayMode: .inline)
    }
    
    // 📍 Point 5: Rendering Each Question
    
    // Builds the UI for a single question and its answer options
    func questionView(for index: Int) -> some View {
        let question = questions[index]   // Get the question for this index
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("Question \(index + 1):")    // Question number
                .font(.headline)
            
            Text(question.text)              // Question text
                .font(.title3)
                .padding(.bottom, 5)
            
            // Loop through each answer option for this question
            ForEach(0..<question.options.count, id: \.self) { optionIndex in
                Button(action: {
                    // Set selected answer for this question
                    selectedAnswers[index] = optionIndex
                }) {
                    HStack {
                        Text(question.options[optionIndex])    // Display option text
                        Spacer()
                        // Show checkmark if this option is selected
                        if selectedAnswers[index] == optionIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        // Highlight selected option
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedAnswers[index] == optionIndex ? Color.blue : Color.gray, lineWidth: 1)
                    )
                }
                .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // 📍 Point 6: Answer Validation
    
    // Checks if all questions have been answered
    var allQuestionsAnswered: Bool {
        !selectedAnswers.contains(nil)
    }
    
    // 📍 Point 7: Submitting and Scoring
    
    // Called when user submits the quiz
    func checkAnswers() {
        score = 0   // Reset score
        for (index, selectedAnswer) in selectedAnswers.enumerated() {
            // Increase score if answer is correct
            if let selectedAnswer = selectedAnswer,
               selectedAnswer == questions[index].correctAnswerIndex {
                score += 1
            }
        }
        showResults = true   // Show the results view
    }
    
    // 📍 Point 8: Resetting the Quiz
    
    // Resets quiz state to allow replay
    func resetQuiz() {
        selectedAnswers = [Int?](repeating: nil, count: questions.count)  // Clear all answers
        score = 0                                                         // Reset score
        showResults = false                                               // Show quiz view again
    }
}

// 📍 Point 9: Results View

// Displays score, feedback, and retry option
struct ResultsView: View {
    let score: Int                      // Final score after submission
    let totalQuestions: Int             // Total number of questions
    let resetQuiz: () -> Void           // Function to restart the quiz
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quiz Results")                       // Title
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Spacer()
            
            Image(systemName: resultImage)             // Feedback icon
                .font(.system(size: 80))
                .foregroundColor(resultColor)
                .padding()
            
            Text("Your Score")                         // Score label
                .font(.title2)
            
            Text("\(score) out of \(totalQuestions)")  // Display score
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(resultColor)
            
            Text(resultMessage)                        // Motivation message
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button(action: resetQuiz) {
                Text("Try Again")                      // Retry button
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
        .padding()
    }
    
    // 📍 Point 10: Dynamic Icon Based on Score
    
    // Returns icon name based on performance
    var resultImage: String {
        let percentage = Double(score) / Double(totalQuestions)
        if percentage >= 0.8 {
            return "star.fill"
        } else if percentage >= 0.5 {
            return "hand.thumbsup.fill"
        } else {
            return "book.fill"
        }
    }
    
    // 📍 Point 11: Color Feedback
    
    // Returns color for score and icon
    var resultColor: Color {
        let percentage = Double(score) / Double(totalQuestions)
        if percentage >= 0.8 {
            return .yellow
        } else if percentage >= 0.5 {
            return .blue
        } else {
            return .gray
        }
    }
    
    // 📍 Point 12: Encouraging Message
    
    // Returns a message based on score
    var resultMessage: String {
        let percentage = Double(score) / Double(totalQuestions)
        if percentage == 1.0 {
            return "Perfect! You got all the answers right!"
        } else if percentage >= 0.8 {
            return "Great job! You really know your stuff!"
        } else if percentage >= 0.5 {
            return "Not bad! Keep learning and try again!"
        } else if percentage > 0.0 {
            return "Keep studying and you'll improve!"
        } else {
            return "Time to hit the books and try again!"
        }
    }
}

// 📍 Point 13: Preview

// Preview the content view in Xcode canvas
#Preview {
    ContentView()
}
