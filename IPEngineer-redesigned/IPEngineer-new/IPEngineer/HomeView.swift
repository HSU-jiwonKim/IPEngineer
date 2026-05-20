import SwiftUI

struct HomeView: View {

    @ObservedObject var dataManager = DataManager.shared
    @State private var showQuiz = false

    // 시험일 (2026년 1회 필기시험 가상 일정)
    let examDate: Date = {
        var c = DateComponents(); c.year = 2026; c.month = 6; c.day = 30
        return Calendar.current.date(from: c) ?? Date()
    }()

    let totalGoal = 20

    var dDay: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0)
    }

    var examDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f.string(from: examDate)
    }

    var todayString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        greetingHeader
                        dDayBanner
                        todayCard
                        subjectGrid
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showQuiz) {
                QuizView()
            }
        }
    }

    // MARK: - 인사 헤더
    var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(todayString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.dsTextTertiary)
                Text("안녕하세요, 지원님")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.dsTextPrimary)
            }
            Spacer()
            ZStack {
                Circle().fill(Color.dsBrandSoft)
                Text("JW")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.dsBrand)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.top, 4)
    }

    // MARK: - D-Day 배너
    var dDayBanner: some View {
        let goalProgress: Double = 0.62  // 시험까지 예상 진도 (UI용)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("2026년 1회 필기시험까지")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("D-")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(dDay)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("시험일")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                    Text(examDateString)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 14)

            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.22))
                            .frame(height: 6)
                        Capsule().fill(Color.white)
                            .frame(width: geo.size.width * CGFloat(goalProgress), height: 6)
                    }
                }
                .frame(height: 6)
                HStack {
                    Text("목표 진도 \(Int(goalProgress * 100))% 달성")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                    Text("잘하고 있어요")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4F46E5"), Color(hex: "6366F1")]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - 오늘의 학습
    var todayCard: some View {
        let solved = dataManager.studyRecords.count
        let correct = dataManager.studyRecords.filter { $0.isCorrect }.count
        let accuracy = solved > 0 ? Int(Double(correct) / Double(solved) * 100) : 0

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("오늘의 학습")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.dsTextPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .medium))
                    Text("AI 추천")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.dsBrand)
            }

            HStack(spacing: 0) {
                DSStat(value: "\(solved)", label: "푼 문제", unit: "/ \(totalGoal)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Rectangle().fill(Color.dsBorder).frame(width: 1, height: 36)
                DSStat(value: "\(accuracy)", label: "정확도", unit: "%",
                       color: accuracy >= 60 ? .dsSuccess : .dsTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Rectangle().fill(Color.dsBorder).frame(width: 1, height: 36)
                DSStat(value: "\(correct)", label: "맞은 문제", unit: "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
            }

            Button(action: { showQuiz = true }) {
                HStack {
                    Text(solved == 0 ? "학습 시작하기" : "이어서 풀기")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .buttonStyle(DSPrimaryButtonStyle())
        }
        .dsCard(padding: 18, radius: 22)
    }

    // MARK: - 5과목 그리드
    var subjectGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSSectionHeader(title: "5과목 진도")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<4, id: \.self) { i in
                    subjectMiniCard(style: SubjectStyle.all[i])
                }
            }

            subjectWideCard(style: SubjectStyle.all[4])
        }
    }

    func subjectMiniCard(style: SubjectStyle) -> some View {
        let acc = dataManager.accuracy(for: style.key)
        let count = dataManager.solvedCount(for: style.key)

        return VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(style.tintSoft)
                Image(systemName: style.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(style.tint)
            }
            .frame(width: 32, height: 32)

            Text(style.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.dsTextSecondary)
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(count > 0 ? "\(Int(acc * 100))" : "—")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(count > 0 ? .dsTextPrimary : .dsTextTertiary)
                if count > 0 {
                    Text("%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.dsTextTertiary)
                }
            }

            DSProgressBar(progress: acc, tint: style.tint, height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsCard(padding: 14, radius: 16)
    }

    func subjectWideCard(style: SubjectStyle) -> some View {
        let acc = dataManager.accuracy(for: style.key)
        let count = dataManager.solvedCount(for: style.key)

        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(style.tintSoft)
                Image(systemName: style.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(style.tint)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(style.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.dsTextSecondary)
                DSProgressBar(progress: acc, tint: style.tint, height: 4)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(count > 0 ? "\(Int(acc * 100))" : "—")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(count > 0 ? .dsTextPrimary : .dsTextTertiary)
                if count > 0 {
                    Text("%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.dsTextTertiary)
                }
            }
        }
        .dsCard(padding: 14, radius: 16)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
