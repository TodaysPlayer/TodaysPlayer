// FirebaseMatchListView.swift
import SwiftUI
import FirebaseFirestore

struct FirebaseMatchListView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if isLoading {
                    ProgressView("로딩 중...")
                } else if matches.isEmpty {
                    Text("매치가 없습니다")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(matches, id: \.id) { match in
                        // 👇 NavigationLink로 카드 전체를 감싸기
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            // 간단한 카드 UI
                            VStack(alignment: .leading, spacing: 12) {
                                Text(match.title)
                                    .font(.headline)
                                    .foregroundColor(.primary) // 👈 텍스트 색상 명시
                                
                                Text(match.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(match.matchType == "futsal" ? "풋살" : "축구")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    
                                    Text("\(match.participants.count)/\(match.maxParticipants)명")
                                        .font(.caption)
                                        .foregroundColor(.primary) // 👈 텍스트 색상 명시
                                    
                                    Spacer()
                                    
                                    Text("\(match.price)원")
                                        .font(.caption)
                                        .foregroundColor(.primary) // 👈 텍스트 색상 명시
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                        }
                        .buttonStyle(PlainButtonStyle()) // 👈 기본 버튼 스타일 제거
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            fetchMatches()
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
                        print("❌ Match 디코딩 실패: \(error)")
                        return nil
                    }
                }
                
                await MainActor.run {
                    self.matches = fetchedMatches
                    self.isLoading = false
                    print("✅ 최종 매치 개수: \(self.matches.count)")
                }
                
            } catch {
                print("❌ 에러: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
