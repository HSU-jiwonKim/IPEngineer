import SwiftUI

// MARK: - 오답 모델
struct WrongNote: Identifiable, Codable {
    let id: UUID
    let subject: String
    let question: String
    let myAnswer: String
    let correctAnswer: String
    let explanation: String
    let wrongCount: Int
    let date: String
    let colorHex: String

    var color: Color { Color(hex: colorHex) }

    init(subject: String, question: String, myAnswer: String, correctAnswer: String, explanation: String, wrongCount: Int, date: String, color: Color) {
        self.id = UUID()
        self.subject = subject
        self.question = question
        self.myAnswer = myAnswer
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.wrongCount = wrongCount
        self.date = date
        self.colorHex = "5BEF8C"
    }

    init(id: UUID = UUID(), subject: String, question: String, myAnswer: String, correctAnswer: String, explanation: String, wrongCount: Int, date: String, colorHex: String) {
        self.id = id
        self.subject = subject
        self.question = question
        self.myAnswer = myAnswer
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.wrongCount = wrongCount
        self.date = date
        self.colorHex = colorHex
    }
}

struct WrongNoteQuizItem: Identifiable {
    let id = UUID()
    let index: Int
}

struct WrongNoteView: View {

    @ObservedObject var dataManager = DataManager.shared
    @State private var selectedFilter = 0
    @State private var expandedId: UUID? = nil
    @State private var quizItem: WrongNoteQuizItem? = nil

    let filters = ["전체", "데이터베이스", "운영체제", "소프트웨어공학", "데이터통신", "전자계산기"]

    var filteredNotes: [WrongNote] {
        if selectedFilter == 0 { return dataManager.wrongNotes }
        let subject = filters[selectedFilter]
        return dataManager.wrongNotes.filter { $0.subject == subject }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    filterBar
                    if dataManager.wrongNotes.isEmpty {
                        emptyView
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(filteredNotes) { note in
                                    wrongCard(note: note)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $quizItem) { item in
                QuizView(startIndex: item.index, filterSubject: nil)
            }
        }
    }

    // MARK: - 헤더
    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("오답 노트")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.dsTextPrimary)
                Text("총 \(dataManager.wrongNotes.count)개 · AI 자동 분류")
                    .font(.system(size: 13))
                    .foregroundColor(.dsTextTertiary)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.dsDanger)
                Text("\(dataManager.wrongNotes.reduce(0) { $0 + $1.wrongCount })")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.dsTextPrimary)
                Text("틀린횟수")
                    .font(.system(size: 11))
                    .foregroundColor(.dsTextTertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.dsDangerSoft)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - 필터바
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(0..<filters.count, id: \.self) { i in
                    Button(action: { selectedFilter = i }) {
                        Text(filters[i])
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedFilter == i ? .white : .dsTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedFilter == i ? Color.dsTextPrimary : Color.dsSurface)
                            .overlay(
                                Capsule()
                                    .stroke(selectedFilter == i ? Color.clear : Color.dsBorder, lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
    }

    // MARK: - 빈 화면
    var emptyView: some View {
        VStack(spacing: 14) {
            Spacer()
            ZStack {
                Circle().fill(Color.dsSuccessSoft).frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.dsSuccess)
            }
            Text("아직 오답이 없어요")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.dsTextPrimary)
            Text("문제를 풀면 틀린 문제가 여기에 저장됩니다")
                .font(.system(size: 13))
                .foregroundColor(.dsTextTertiary)
            Spacer()
            Spacer()
        }
    }

    // MARK: - 오답 카드
    func wrongCard(note: WrongNote) -> some View {
        let isExpanded = expandedId == note.id

        return VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expandedId = isExpanded ? nil : note.id
                }
            }) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        DSChip(text: note.subject, tint: .dsTextSecondary, background: .dsSurfaceAlt)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 10, weight: .semibold))
                            Text("\(note.wrongCount)회 틀림")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.dsDanger)
                    }

                    Text(note.question)
                        .font(.system(size: 14))
                        .foregroundColor(.dsTextPrimary)
                        .lineLimit(isExpanded ? nil : 2)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text(note.date)
                            .font(.system(size: 11))
                            .foregroundColor(.dsTextTertiary)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.dsTextTertiary)
                    }
                }
                .padding(16)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Rectangle().fill(Color.dsBorder).frame(height: 1)

                    VStack(spacing: 8) {
                        answerRow(label: "내 답", text: note.myAnswer, color: .dsDanger, bg: .dsDangerSoft)
                        answerRow(label: "정답", text: note.correctAnswer, color: .dsSuccess, bg: .dsSuccessSoft)
                    }

                    HStack(alignment: .top, spacing: 10) {
                        ZStack {
                            Circle().fill(Color.dsBrand)
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 22, height: 22)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AI 핵심 요약")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.dsBrand)
                            Text(note.explanation)
                                .font(.system(size: 13))
                                .foregroundColor(.dsBrandText)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(Color.dsBrandSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button(action: {
                        let idx = sampleQuestions.firstIndex(where: { $0.question == note.question }) ?? 0
                        quizItem = WrongNoteQuizItem(index: idx)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12, weight: .semibold))
                            Text("다시 풀기")
                        }
                    }
                    .buttonStyle(DSPrimaryButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.dsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dsBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    func answerRow(label: String, text: String, color: Color, bg: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32, alignment: .leading)
                .padding(.top, 1)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.dsTextPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct WrongNoteView_Previews: PreviewProvider {
    static var previews: some View {
        WrongNoteView()
    }
}
