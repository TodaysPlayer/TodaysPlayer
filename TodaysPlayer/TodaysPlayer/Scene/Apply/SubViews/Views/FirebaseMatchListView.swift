//
//  FirebaseMatchListView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/24/25.
//

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
                ForEach(filterViewModel.matches, id: \.id) { match in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            MatchCardView(match: match)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
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
                    .foregroundColor(isFavorited ? .primaryBaseGreen : .primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
}
