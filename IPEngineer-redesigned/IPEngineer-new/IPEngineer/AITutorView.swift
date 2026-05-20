import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let time: String

    enum Role { case ai, user }
}

struct AITutorView: View {

    @State private var messages: [ChatMessage] = [
        ChatMessage(
            role: .ai,
            content: "안녕하세요! 정보처리기사 5과목 무엇이든 물어보세요. 핵심만 간결하게 설명해드릴게요.",
            time: "방금"
        )
    ]
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var selectedTab = 0

    let tabs = ["개념 설명", "오답 분석", "모의고사", "암기카드"]
    let quickQuestions = ["정규화 1NF~3NF", "OSI 7계층", "디자인 패턴", "SQL JOIN", "프로세스 스케줄링"]

    let apiKey = "AIzaSyBOSnurVHlyNzyGnvAasMOg6vyhdpGUjuA"

    var body: some View {
        NavigationView {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    tabBar
                    messageList
                    quickBar
                    inputBar
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - 헤더
    var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F46E5"), Color(hex: "8B5CF6")]),
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text("AI 튜터")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.dsTextPrimary)
                HStack(spacing: 5) {
                    Circle().fill(Color.dsSuccess).frame(width: 6, height: 6)
                    Text("온라인 · 즉시 답변")
                        .font(.system(size: 11))
                        .foregroundColor(.dsTextTertiary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.dsSurface)
        .overlay(Rectangle().fill(Color.dsBorder).frame(height: 1), alignment: .bottom)
    }

    // MARK: - 탭바
    var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    Button(action: { selectedTab = i }) {
                        Text(tabs[i])
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedTab == i ? .white : .dsTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedTab == i ? Color.dsTextPrimary : Color.dsSurface)
                            .overlay(
                                Capsule()
                                    .stroke(selectedTab == i ? Color.clear : Color.dsBorder, lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .background(Color.dsBackground)
    }

    // MARK: - 메시지 리스트
    var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { msg in
                        messageRow(msg: msg).id(msg.id)
                    }
                    if isLoading { loadingBubble }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
        }
    }

    func messageRow(msg: ChatMessage) -> some View {
        Group {
            if msg.role == .ai {
                HStack(alignment: .top, spacing: 8) {
                    ZStack {
                        Circle().fill(Color.dsBrand)
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(msg.content)
                            .font(.system(size: 14))
                            .foregroundColor(.dsTextPrimary)
                            .lineSpacing(5)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(Color.dsSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.dsBorder, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text(msg.time)
                            .font(.system(size: 10))
                            .foregroundColor(.dsTextTertiary)
                    }
                    .frame(maxWidth: 260, alignment: .leading)
                    Spacer(minLength: 0)
                }
            } else {
                HStack(alignment: .top, spacing: 8) {
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(msg.content)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineSpacing(5)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(Color.dsBrand)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text(msg.time)
                            .font(.system(size: 10))
                            .foregroundColor(.dsTextTertiary)
                    }
                    .frame(maxWidth: 260, alignment: .trailing)
                    ZStack {
                        Circle().fill(Color.dsBrandSoft)
                        Text("JW")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.dsBrand)
                    }
                    .frame(width: 28, height: 28)
                }
            }
        }
    }

    var loadingBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                Circle().fill(Color.dsBrand)
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 28)

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Color.dsTextTertiary).frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.dsSurface)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.dsBorder, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer()
        }
    }

    // MARK: - 빠른 질문
    var quickBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(quickQuestions, id: \.self) { q in
                    Button(action: {
                        inputText = q
                        sendMessage()
                    }) {
                        Text(q)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.dsTextSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.dsSurface)
                            .overlay(Capsule().stroke(Color.dsBorder, lineWidth: 1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - 입력바
    var inputBar: some View {
        HStack(spacing: 8) {
            TextField("정처기 관련 무엇이든 물어보세요", text: $inputText)
                .font(.system(size: 14))
                .foregroundColor(.dsTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.dsSurface)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.dsBorder, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button(action: { sendMessage() }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(inputText.isEmpty || isLoading ? Color.dsTextTertiary : Color.dsTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(inputText.isEmpty || isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Color.dsBackground)
        .overlay(Rectangle().fill(Color.dsBorder).frame(height: 1), alignment: .top)
    }

    // MARK: - API
    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        messages.append(ChatMessage(role: .user, content: text, time: getTime()))
        isLoading = true
        callAPI(userMessage: text) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                self.messages.append(ChatMessage(role: .ai, content: response, time: self.getTime()))
            }
        }
    }

    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }

    func callAPI(userMessage: String, completion: @escaping (String) -> Void) {
        let systemPrompt = "당신은 정보처리기사 전문 AI 튜터입니다. 5과목에 대해서만 답변하세요. 핵심만 간결하게 200자 이내로 답변하세요."
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion("URL 오류")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "system_instruction": ["parts": [["text": systemPrompt]]],
            "contents": [["parts": [["text": userMessage]]]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion("요청 오류")
            return
        }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("네트워크 오류: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion("데이터 없음")
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                completion(text)
            } else {
                completion("응답 파싱 오류")
            }
        }.resume()
    }
}

struct AITutorView_Previews: PreviewProvider {
    static var previews: some View {
        AITutorView()
    }
}
