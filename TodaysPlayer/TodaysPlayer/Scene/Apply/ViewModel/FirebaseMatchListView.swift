// FirebaseMatchListView.swift
import SwiftUI
import FirebaseFirestore

struct FirebaseMatchListView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    
    // 부모 뷰(ApplyView)로부터 선택된 날짜 받기
    var selectedDate: Date
    
    // ⭐️ TODO: 로그인 완성 후 수정 필요!
    // ========================================
    // [방법 1] AuthManager 사용하는 경우:
    // @EnvironmentObject var authManager: AuthManager
    // 그리고 아래 currentUserId 부분을 authManager.currentUserId로 변경
    //
    // [방법 2] Firebase Auth 직접 사용하는 경우:
    // import FirebaseAuth 추가
    // Auth.auth().currentUser?.uid ?? "temp_user_id"로 변경
    // ========================================
    private var currentUserId: String {
        "temp_user_id" // 임시 ID - 로그인 완성 후 실제 사용자 ID로 교체!
    }
    
    // 날짜별 필터링된 매치
    private var filteredMatches: [Match] {
        matches.filter { match in
            Calendar.current.isDate(match.dateTime, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if isLoading {
                    ProgressView("로딩 중...")
                } else if matches.isEmpty {
                    Text("매치가 없습니다")
                        .foregroundColor(.secondary)
                        .padding()
                } else if filteredMatches.isEmpty {
                    // 선택한 날짜에 매치가 없을 때
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("선택한 날짜에 매치가 없습니다")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    // matches 대신 filteredMatches 사용
                    ForEach(filteredMatches, id: \.id) { match in
                        NavigationLink(destination: MatchDetailView(
                            match: match,
                            currentUserId: "temp_user_id" // 임시 아이디 추가
                        )) {
                            VStack(alignment: .leading, spacing: 12) {
                                // 1️⃣ 풋살/축구 태그
                                HStack {
                                    Text(match.matchType == "futsal" ? "풋살" : "축구")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(match.matchType == "futsal" ? Color.green : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    
                                    Spacer()
                                }
                                
                                // 2️⃣ 제목
                                Text(match.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                // 3️⃣ 시간 (시작 시간만)
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Text(match.dateTime.formatForDisplay())
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                
                                // 4️⃣ 장소명
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Text(match.location.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                
                                // 5️⃣ 인원 / 참가비 / 성별 / 실력 (간격 넓힘)
                                HStack(spacing: 16) {
                                    // 인원
                                    HStack(spacing: 2) {
                                        Image(systemName: "person.2")
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                        Text("\(match.participants.count)/\(match.maxParticipants)명")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    // 참가비
                                    HStack(spacing: 2) {
                                        Image(systemName: "wonsign.circle")
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                        Text(match.price == 0 ? "무료" : "\(match.price)원")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    // 성별
                                    Text(match.genderKorean)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    
                                    // 실력
                                    Text(skillLevelKorean(match.skillLevel))
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            fetchMatches()
        }
    }
    
    // 실력 레벨을 한글로 변환하는 헬퍼 함수
    private func skillLevelKorean(_ level: String) -> String {
        switch level.lowercased() {
        case "beginner": return "입문자"
        case "amateur": return "초급"
        case "elite": return "중급"
        case "professional": return "상급"
        default: return "무관"
        }
    }
    
    // Firebase에서 데이터 가져오기
    func fetchMatches() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let snapshot = try await Firestore.firestore()
                    .collection("matches")
                    .order(by: "createdAt", descending: true)
                    .getDocuments()
                
                let documents = snapshot.documents
                print("✅ 문서 \(documents.count)개 발견")
                
                let fetchedMatches = documents.compactMap { doc in
                    let decoder = Firestore.Decoder()
                    decoder.userInfo[Match.documentIdKey] = doc.documentID
                    
                    do {
                        let match = try doc.data(as: Match.self, decoder: decoder)
                        print("✅ Match 디코딩 성공: \(match.title)")
                        return match
                    } catch {
                        print("Match 디코딩 실패: \(error)")
                        return nil
                    }
                }
                
                await MainActor.run {
                    self.matches = fetchedMatches
                    self.isLoading = false
                    print("✅ 최종 매치 개수: \(self.matches.count)")
                }
                
            } catch {
                print("에러: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
