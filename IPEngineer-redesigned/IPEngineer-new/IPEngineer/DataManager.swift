
import Foundation
import SwiftUI

// MARK: - 학습 기록 모델
struct StudyRecord: Codable {
    let questionId: Int
    let subject: String
    let isCorrect: Bool
    let date: Date
}

// MARK: - DataManager
class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    @Published var studyRecords: [StudyRecord] = []
    @Published var wrongNotes: [WrongNote] = []
    
    private let recordsKey = "studyRecords"
    private let wrongKey = "wrongNotes"
    
    init() {
        loadRecords()
        loadWrongNotes()
    }
    
    // MARK: - 학습 기록 저장
    func saveRecord(questionId: Int, subject: String, isCorrect: Bool) {
        let record = StudyRecord(
            questionId: questionId,
            subject: subject,
            isCorrect: isCorrect,
            date: Date()
        )
        studyRecords.append(record)
        saveRecords()
        
        if !isCorrect {
            addWrongNote(questionId: questionId)
        }
    }
    
    // MARK: - 과목별 정답률
    func accuracy(for subject: String) -> Double {
        let filtered = studyRecords.filter { $0.subject == subject }
        guard !filtered.isEmpty else { return 0 }
        let correct = filtered.filter { $0.isCorrect }.count
        return Double(correct) / Double(filtered.count)
    }
    
    // MARK: - 전체 정답률
    func totalAccuracy() -> Double {
        guard !studyRecords.isEmpty else { return 0 }
        let correct = studyRecords.filter { $0.isCorrect }.count
        return Double(correct) / Double(studyRecords.count)
    }
    
    // MARK: - 과목별 풀이 수
    func solvedCount(for subject: String) -> Int {
        return studyRecords.filter { $0.subject == subject }.count
    }
    
    // MARK: - 오답노트 추가
    func addWrongNote(questionId: Int) {
        guard let question = sampleQuestions.first(where: { $0.id == questionId }) else { return }
        
        if let index = wrongNotes.firstIndex(where: { $0.question == question.question }) {
            let old = wrongNotes[index]
            wrongNotes.remove(at: index)
            let updated = WrongNote(
                id: old.id,
                subject: old.subject,
                question: old.question,
                myAnswer: old.myAnswer,
                correctAnswer: old.correctAnswer,
                explanation: old.explanation,
                wrongCount: old.wrongCount + 1,
                date: "방금",
                colorHex: old.colorHex
            )
            wrongNotes.insert(updated, at: 0)
        } else {
            let note = WrongNote(
                subject: question.subject,
                question: question.question,
                myAnswer: "오답",
                correctAnswer: question.options[question.answer],
                explanation: question.explanation,
                wrongCount: 1,
                date: "방금",
                colorHex: subjectColorHex(question.subject)
            )
            wrongNotes.insert(note, at: 0)
        }
        saveWrongNotes()
    }
    
    // MARK: - 과목별 색상 hex
    func subjectColorHex(_ subject: String) -> String {
        switch subject {
        case "소프트웨어설계":  return "7B68EE"
        case "소프트웨어개발":  return "EF8C5B"
        case "데이터베이스":    return "5BC0EF"
        case "프로그래밍언어":  return "C05BEF"
        default:               return "5BEF8C"
        }
    }
    
    // MARK: - UserDefaults 저장/불러오기
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(studyRecords) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let records = try? JSONDecoder().decode([StudyRecord].self, from: data) {
            studyRecords = records
        }
    }
    
    private func saveWrongNotes() {
        if let data = try? JSONEncoder().encode(wrongNotes) {
            UserDefaults.standard.set(data, forKey: wrongKey)
        }
    }
    
    private func loadWrongNotes() {
        if let data = UserDefaults.standard.data(forKey: wrongKey),
           let notes = try? JSONDecoder().decode([WrongNote].self, from: data) {
            wrongNotes = notes
        }
    }
    
    // MARK: - 데이터 초기화
    func resetAll() {
        studyRecords = []
        wrongNotes = []
        UserDefaults.standard.removeObject(forKey: recordsKey)
        UserDefaults.standard.removeObject(forKey: wrongKey)
    }
}
