// FirebaseMatchListView.swift
import SwiftUI
import FirebaseFirestore

struct FirebaseMatchListView: View {
    @EnvironmentObject var filterViewModel: FilterViewModel
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    private var currentUserId: String {
        AuthHelper.currentUserId
    }
    
    var body: some View {
        Group {
            if filterViewModel.isLoading {
                ProgressView("로딩 중...")
                    .padding(.top, 40)
            } else if filterViewModel.matches.isEmpty {
                // 매치가 없을 때
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("조건에 맞는 매치가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
            } else {
                // ViewModel의 matches 표시
                ForEach(filterViewModel.matches, id: \.id) { match in
                    ZStack(alignment: .topTrailing) {
                        // 기존 카드 (NavigationLink)
                        NavigationLink(destination: MatchDetailView(
                            match: match
                        )) {
                            VStack(alignment: .leading, spacing: 12) {
                                // 2️⃣ 제목
                                Text(match.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
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
                                    
                                    // 내 글이 아닐때만 북마크 공간 확보
                                    if match.organizerId != AuthHelper.currentUserId {
                                        Color.clear
                                            .frame(width: 44, height: 44)
                                    }
                                }
                                
                                // 3️⃣ 시간
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
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 북마크 버튼
                        BookmarkButton(
                            match: match,
                            isFavorited: favoriteViewModel.isFavorited(matchId: match.id),
                            action: {
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
        }
        .refreshable {
            filterViewModel.applyFilter()
        }
        .onAppear {
            filterViewModel.applyFilter()
        }
    }
    
    // 실력 레벨을 한글로 변환하는 헬퍼 함수
    private func skillLevelKorean(_ level: String) -> String {
        switch level.lowercased() {
        case "beginner": return "초급"
        case "intermediate": return "중급"
        case "advanced": return "고급"
        case "expert": return "상급"
        default: return "무관"
        }
    }
}

// MARK: - 북마크 버튼 컴포넌트
struct BookmarkButton: View {
    let match: Match
    let isFavorited: Bool
    let action: () -> Void
    
    private var isMyMatch: Bool {
        match.organizerId == AuthHelper.currentUserId
    }
    
    var body: some View {
        // 내가 작성한 글이면 아예 렌더링 안 함
        if !isMyMatch {
            Button(action: action) {
                Image(systemName: isFavorited ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(isFavorited ? .blue : .primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
}
