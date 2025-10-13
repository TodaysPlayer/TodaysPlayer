// FirebaseMatchListView.swift
import SwiftUI
import FirebaseFirestore

struct FirebaseMatchListView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    
    // 부모 뷰(ApplyView)로부터 선택된 날짜 받기
    var selectedDate: Date
    
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
                    // MatchItemView 사용
                    ForEach(filteredMatches, id: \.id) { match in
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            MatchItemView(
                                location: match.location.name,
                                address: match.location.address,
                                distance: "0km", // TODO: 거리 계산 필요하면 추가
                                time: match.dateTime.formatForDisplay(),
                                participants: "\(match.participants.count)/\(match.maxParticipants)",
                                gender: GenderType(rawValue: match.gender) ?? .mixed,
                                rating: match.rating != nil ? String(format: "%.1f", match.rating!) : "0.0",
                                price: match.price == 0 ? "무료" : "\(match.price)원",
                                skillLevel: skillLevelKorean(match.skillLevel),
                                tags: match.createMatchTags()
                            )
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
