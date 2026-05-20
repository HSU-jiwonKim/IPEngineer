//
//  DesignSystem.swift
//  IPEngineer
//
//  통합 디자인 시스템 — 컬러, 타이포, 카드 modifier
//

import SwiftUI

// MARK: - 컬러 팔레트
extension Color {
    // 배경
    static let dsBackground   = Color(hex: "FAFAF7")
    static let dsSurface      = Color(hex: "FFFFFF")
    static let dsSurfaceAlt   = Color(hex: "F4F4F0")
    static let dsBorder       = Color(hex: "EEEDE8")

    // 텍스트
    static let dsTextPrimary   = Color(hex: "1A1A1F")
    static let dsTextSecondary = Color(hex: "5C5C66")
    static let dsTextTertiary  = Color(hex: "8A8A94")

    // 브랜드
    static let dsBrand        = Color(hex: "4F46E5")
    static let dsBrandSoft    = Color(hex: "EEF2FF")
    static let dsBrandText    = Color(hex: "312E81")

    // 시맨틱
    static let dsSuccess      = Color(hex: "10B981")
    static let dsSuccessSoft  = Color(hex: "ECFDF5")
    static let dsSuccessText  = Color(hex: "065F46")

    static let dsDanger       = Color(hex: "EF4444")
    static let dsDangerSoft   = Color(hex: "FEF2F2")
    static let dsDangerText   = Color(hex: "991B1B")

    static let dsWarning      = Color(hex: "F59E0B")
    static let dsWarningSoft  = Color(hex: "FFFBEB")
    static let dsWarningText  = Color(hex: "92400E")
}

// MARK: - 5과목 스타일
struct SubjectStyle {
    let key: String
    let name: String
    let detail: String
    let initial: String
    let symbol: String
    let tint: Color
    let tintSoft: Color

    static let all: [SubjectStyle] = [
        SubjectStyle(
            key: "소프트웨어설계", name: "소프트웨어 설계",
            detail: "UML · 디자인패턴 · 요구사항", initial: "설",
            symbol: "square.stack.3d.up.fill",
            tint: Color(hex: "6366F1"), tintSoft: Color(hex: "EEF2FF")
        ),
        SubjectStyle(
            key: "소프트웨어개발", name: "소프트웨어 개발",
            detail: "자료구조 · 알고리즘 · 테스트", initial: "개",
            symbol: "hammer.fill",
            tint: Color(hex: "F97316"), tintSoft: Color(hex: "FFF1EB")
        ),
        SubjectStyle(
            key: "데이터베이스", name: "데이터베이스 구축",
            detail: "SQL · 정규화 · 트랜잭션", initial: "DB",
            symbol: "cylinder.split.1x2.fill",
            tint: Color(hex: "06B6D4"), tintSoft: Color(hex: "ECFEFF")
        ),
        SubjectStyle(
            key: "프로그래밍언어", name: "프로그래밍 언어",
            detail: "C · Java · Python · Shell", initial: "</>",
            symbol: "chevron.left.forwardslash.chevron.right",
            tint: Color(hex: "A855F7"), tintSoft: Color(hex: "FAF5FF")
        ),
        SubjectStyle(
            key: "정보시스템", name: "정보시스템 구축관리",
            detail: "보안 · 네트워크 · PM", initial: "보",
            symbol: "shield.lefthalf.filled",
            tint: Color(hex: "10B981"), tintSoft: Color(hex: "ECFDF5")
        )
    ]

    static func style(for key: String) -> SubjectStyle {
        all.first(where: { $0.key == key }) ?? all[0]
    }
}

// MARK: - 카드 modifier
struct DSCard: ViewModifier {
    var padding: CGFloat = 18
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.dsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.dsBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

extension View {
    func dsCard(padding: CGFloat = 18, radius: CGFloat = 20) -> some View {
        modifier(DSCard(padding: padding, radius: radius))
    }
}

// MARK: - 칩
struct DSChip: View {
    var text: String
    var tint: Color = .dsTextSecondary
    var background: Color = .dsSurfaceAlt
    var bold: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: bold ? .semibold : .medium))
            .foregroundColor(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(Capsule())
    }
}

// MARK: - 섹션 헤더
struct DSSectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.dsTextPrimary)
            Spacer()
            if let trailing = trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.dsBrand)
            }
        }
    }
}

// MARK: - 진도바
struct DSProgressBar: View {
    let progress: Double
    var tint: Color = .dsBrand
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.dsSurfaceAlt)
                    .frame(height: height)
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * CGFloat(min(max(progress, 0), 1)), height: height)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Primary 버튼 스타일
struct DSPrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(enabled ? .white : .dsTextTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(enabled ? Color.dsTextPrimary : Color.dsSurfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct DSSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.dsTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.dsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.dsBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - 통계 한 줄
struct DSStat: View {
    let value: String
    let label: String
    var unit: String = ""
    var color: Color = .dsTextPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(color)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.dsTextTertiary)
                }
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.dsTextTertiary)
        }
    }
}
