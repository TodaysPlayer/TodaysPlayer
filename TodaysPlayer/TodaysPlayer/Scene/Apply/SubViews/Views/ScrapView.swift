//
//  ScrapView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/28/25.
//

import SwiftUI

struct ScrapView: View {
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    @State private var scrapedMatches: [Match] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if isLoading {
                // 로딩 중
                ProgressView("로딩 중...")
            } else if scrapedMatches.isEmpty {
                // 스크랩한 매치가 없을 때
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("찜한 매치가 없습니다")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("마음에 드는 매치를 찜해보세요!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                // 스크랩한 매치 목록
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(scrapedMatches, id: \.id) { match in
                            ZStack(alignment: .topTrailing) {
                                // 매치 카드 (NavigationLink)
                                NavigationLink(destination: MatchDetailView(match: match)) {
                                    MatchCardView(match: match)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // 북마크 버튼
                                BookmarkButton(
                                    match: match,
                                    isFavorited: favoriteViewModel.isFavorited(matchId: match.id),
                                    action: {
                                        // 먼저 로컬에서 즉시 제거
                                        withAnimation {
                                            scrapedMatches.removeAll { $0.id == match.id }
                                        }
                                        
                                        // 그 다음 Firebase 삭제 (백그라운드)
                                        favoriteViewModel.toggleFavorite(
                                            matchId: match.id,
                                            organizerId: match.organizerId
                                        )
                                    }
                                )
                                .padding(8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle("찜한 매치")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadScrapedMatches()
        }
        .refreshable {
            loadScrapedMatches()
        }
    }
    
    // 스크랩한 매치 불러오기
    private func loadScrapedMatches() {
        isLoading = true
        
        favoriteViewModel.fetchFavoritedMatches { matches in
            withAnimation {
                self.scrapedMatches = matches
                self.isLoading = false
            }
        }
    }
}

// MARK: - 매치 카드 컴포넌트 (FirebaseMatchListView와 동일)
struct MatchCardView: View {
    let match: Match
    
    var body: some View {
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
                
                // 북마크 공간 확보
                Color.clear
                    .frame(width: 44, height: 44)
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
            
            // 5️⃣ 인원 / 참가비 / 성별 / 실력
            HStack(spacing: 16) {
                // 인원
                HStack(spacing: 2) {
                    Image(systemName: "person.2")
                        .font(.caption2)
                        .foregroundColor(.primary)
                    Text("\(match.appliedParticipantsCount)/\(match.maxParticipants)명")
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
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
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
}

#Preview {
    NavigationStack {
        ScrapView()
            .environmentObject(FavoriteViewModel())
    }
}
