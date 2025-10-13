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
                    // matches 대신 filteredMatches 사용
                    ForEach(filteredMatches, id: \.id) { match in
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(match.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(match.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // 날짜/시간 표시
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text(match.dateTime.formatForDisplay())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
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
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(match.price)원")
                                        .font(.caption)
                                        .foregroundColor(.primary)
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
