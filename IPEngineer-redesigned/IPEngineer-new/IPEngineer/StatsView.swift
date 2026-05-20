import SwiftUI

struct StatsView: View {

    @ObservedObject var dataManager = DataManager.shared
    @State private var showResetAlert = false

    let weakPoints: [(topic: String, subject: String, accuracy: String)] = [
        ("네트워크 보안 프로토콜",  "정보시스템 구축관리", "38%"),
        ("정규화 & 이상(Anomaly)", "데이터베이스 구축",    "52%"),
        ("디자인 패턴 (GoF 23종)", "소프트웨어 설계",     "57%"),
        ("포인터 & 동적 메모리",   "프로그래밍 언어",     "61%")
    ]

    let calendarData: [[Int]] = [
        [0, 1, 1, 1, 1, 1, 4],
        [1, 1, 1, 1, 1, 2, 3],
        [3, 3, 3, 3, 3, 3, 3],
        [3, 3, 3, 3, 3, 3, 3]
    ]
    let dayLabels = ["일","월","화","수","목","금","토"]

    var totalSolved: Int { dataManager.studyRecords.count }
    var totalCorrect: Int { dataManager.studyRecords.filter { $0.isCorrect }.count }
    var avgScore: Int {
        guard totalSolved > 0 else { return 0 }
        return Int(Double(totalCorrect) / Double(totalSolved) * 100)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        passPredictionCard
                        subjectStatsSection
                        weakPointsCard
                        calendarCard
                        resetCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("학습 기록 초기화"),
                    message: Text("모든 학습 기록과 오답 노트가 삭제됩니다. 정말 초기화하시겠어요?"),
                    primaryButton: .destructive(Text("초기화")) {
                        dataManager.resetAll()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("학습 통계")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.dsTextPrimary)
            Text("총 \(totalSolved)문제 풀이 · \(totalCorrect)개 정답")
                .font(.system(size: 13))
                .foregroundColor(.dsTextTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - 합격 예측
    var passPredictionCard: some View {
        let isPass = avgScore >= 60

        return HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.dsSurfaceAlt, lineWidth: 8)
                    .frame(width: 92, height: 92)
                Circle()
                    .trim(from: 0, to: totalSolved > 0 ? CGFloat(avgScore) / 100 : 0)
                    .stroke(
                        isPass ? Color.dsSuccess : Color.dsBrand,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 92, height: 92)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(avgScore)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.dsTextPrimary)
                    Text("점")
                        .font(.system(size: 11))
                        .foregroundColor(.dsTextTertiary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("현재 평균")
                    .font(.system(size: 12))
                    .foregroundColor(.dsTextTertiary)

                Text(totalSolved == 0 ? "기록 없음" :
                     isPass ? "합격권" : "합격 기준 미달")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(totalSolved == 0 ? .dsTextSecondary :
                                     isPass ? .dsSuccess : .dsDanger)

                HStack(spacing: 5) {
                    Image(systemName: isPass ? "checkmark.circle.fill" :
                          totalSolved == 0 ? "info.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                    Text(totalSolved == 0 ? "문제를 풀어 통계를 시작하세요" :
                         isPass ? "합격 기준 60점 통과" : "60점 미만 — 더 풀어보세요")
                        .font(.system(size: 12))
                }
                .foregroundColor(.dsTextTertiary)
            }
            Spacer()
        }
        .dsCard(padding: 18, radius: 22)
    }

    // MARK: - 과목별
    var subjectStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSSectionHeader(title: "과목별 정답률")
            VStack(spacing: 10) {
                ForEach(SubjectStyle.all, id: \.key) { style in
                    subjectRow(style: style)
                }
            }
        }
    }

    func subjectRow(style: SubjectStyle) -> some View {
        let acc = dataManager.accuracy(for: style.key)
        let count = dataManager.solvedCount(for: style.key)
        let score = Int(acc * 100)
        let isDanger = count > 0 && score < 40

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(style.tintSoft)
                Image(systemName: style.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(style.tint)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(style.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.dsTextPrimary)
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(count > 0 ? "\(score)" : "—")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(count == 0 ? .dsTextTertiary :
                                             isDanger ? .dsDanger : .dsTextPrimary)
                        if count > 0 {
                            Text("점")
                                .font(.system(size: 11))
                                .foregroundColor(.dsTextTertiary)
                        }
                    }
                }
                DSProgressBar(progress: acc, tint: isDanger ? .dsDanger : style.tint, height: 4)
                HStack {
                    Text("\(count)문제")
                        .font(.system(size: 11))
                        .foregroundColor(.dsTextTertiary)
                    if isDanger {
                        Text("· 40점 미달 위험")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.dsDanger)
                    }
                    Spacer()
                }
            }
        }
        .dsCard(padding: 14, radius: 16)
    }

    // MARK: - 약점
    var weakPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.dsDanger)
                    Text("AI 약점 분석 TOP 4")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.dsTextPrimary)
                }
                Spacer()
                Text("전체보기")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.dsBrand)
            }

            VStack(spacing: 8) {
                ForEach(0..<weakPoints.count, id: \.self) { i in
                    weakRow(index: i)
                }
            }
        }
        .dsCard(padding: 16, radius: 20)
    }

    func weakRow(index: Int) -> some View {
        let w = weakPoints[index]
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7).fill(Color.dsDangerSoft)
                Text("\(index + 1)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.dsDanger)
            }
            .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(w.topic)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.dsTextPrimary)
                Text(w.subject)
                    .font(.system(size: 11))
                    .foregroundColor(.dsTextTertiary)
            }
            Spacer()
            Text(w.accuracy)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.dsDanger)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.dsSurfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 달력
    var calendarCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.dsTextPrimary)
                    Text("학습 달력")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.dsTextPrimary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.dsWarning)
                    Text("연속 \(continuousStreak())일")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.dsWarningText)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.dsWarningSoft)
                .clipShape(Capsule())
            }

            HStack(spacing: 0) {
                ForEach(dayLabels, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.dsTextTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: 5) {
                ForEach(0..<calendarData.count, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<calendarData[row].count, id: \.self) { col in
                            calendarCell(day: row * 7 + col + 1, type: calendarData[row][col])
                        }
                    }
                }
            }

            HStack(spacing: 14) {
                legendItem(color: .dsBrandSoft, label: "학습완료")
                legendItem(color: .dsBrand, label: "오늘")
                legendItem(color: .dsDangerSoft, label: "미완료")
                Spacer()
            }
            .padding(.top, 2)
        }
        .dsCard(padding: 16, radius: 20)
    }

    func calendarCell(day: Int, type: Int) -> some View {
        let bg: Color = {
            switch type {
            case 1: return .dsBrandSoft
            case 2: return .dsBrand
            case 4: return .dsDangerSoft
            default: return .clear
            }
        }()
        let textColor: Color = {
            switch type {
            case 1: return .dsBrand
            case 2: return .white
            case 4: return .dsDanger
            default: return .dsTextTertiary
            }
        }()

        return ZStack {
            RoundedRectangle(cornerRadius: 8).fill(bg)
            if type != 0 {
                Text("\(day)")
                    .font(.system(size: 11, weight: type == 2 ? .semibold : .medium))
                    .foregroundColor(textColor)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.dsTextTertiary)
        }
    }

    // MARK: - 초기화
    var resetCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9).fill(Color.dsDangerSoft)
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.dsDanger)
                }
                .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("학습 기록 초기화")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.dsTextPrimary)
                    Text("모든 풀이 기록과 오답이 삭제됩니다")
                        .font(.system(size: 11))
                        .foregroundColor(.dsTextTertiary)
                }
                Spacer()
            }
            Button(action: { showResetAlert = true }) {
                Text("전체 초기화")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.dsDanger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.dsDangerSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .dsCard(padding: 16, radius: 20)
    }

    // MARK: - 연속일
    func continuousStreak() -> Int {
        guard !dataManager.studyRecords.isEmpty else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        while true {
            let hasRecord = dataManager.studyRecords.contains {
                calendar.isDate($0.date, inSameDayAs: checkDate)
            }
            if hasRecord {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        return streak
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
