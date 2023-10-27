import Foundation

struct GameRecord: Codable {
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    func isBetter(_ anotherGame: GameRecord) -> Bool {
        return correctAnswers < anotherGame.correctAnswers
    }
    
    func toString(dateFormatter: DateFormatter) -> String {
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return "\(correctAnswers)/\(totalQuestions) (\(dateFormatter.string(from: date)))"
    }
}
