import SwiftUI

// MARK: - QuizLaunchItem
struct QuizLaunchItem: Identifiable {
    let id = UUID()
    let subject: String?
}

struct SubjectView: View {

    @ObservedObject var dataManager = DataManager.shared
    @State private var quizItem: QuizLaunchItem? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        header
                        ForEach(SubjectStyle.all, id: \.key) { style in
                            subjectCard(style: style)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $quizItem) { item in
                QuizView(startIndex: 0, filterSubject: item.subject)
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("과목별 학습")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.dsTextPrimary)
            Text("풀고 싶은 과목을 선택하세요")
                .font(.system(size: 13))
                .foregroundColor(.dsTextTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    func subjectCard(style: SubjectStyle) -> some View {
        let solved = dataManager.solvedCount(for: style.key)
        let acc = dataManager.accuracy(for: style.key)
        let totalPerSubject = sampleQuestions.filter { $0.subject == style.key }.count
        let progress = totalPerSubject > 0 ? Double(solved) / Double(totalPerSubject) : 0

        return VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(style.tintSoft)
                    Image(systemName: style.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(style.tint)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(style.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.dsTextPrimary)
                    Text(style.detail)
                        .font(.system(size: 12))
                        .foregroundColor(.dsTextTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(solved > 0 ? "\(Int(acc * 100))" : "—")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(solved > 0 ? .dsTextPrimary : .dsTextTertiary)
                        if solved > 0 {
                            Text("%")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.dsTextTertiary)
                        }
                    }
                    Text("\(solved) / \(totalPerSubject) 문제")
                        .font(.system(size: 11))
                        .foregroundColor(.dsTextTertiary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                DSProgressBar(progress: progress, tint: style.tint, height: 5)
                HStack {
                    Text(solved == 0 ? "아직 풀지 않은 과목이에요" : "진도율 \(Int(progress * 100))%")
                        .font(.system(size: 11))
                        .foregroundColor(.dsTextTertiary)
                    Spacer()
                }
            }

            HStack(spacing: 8) {
                Button(action: { quizItem = QuizLaunchItem(subject: style.key) }) {
                    Text("기출 풀기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(style.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: { quizItem = QuizLaunchItem(subject: style.key) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 11, weight: .semibold))
                        Text("랜덤")
                    }
                }
                .buttonStyle(DSSecondaryButtonStyle())

                Button(action: { quizItem = QuizLaunchItem(subject: style.key) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 11, weight: .semibold))
                        Text("약점")
                    }
                }
                .buttonStyle(DSSecondaryButtonStyle())
            }
        }
        .dsCard(padding: 16, radius: 20)
    }
}

struct SubjectView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectView()
    }
}
