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
            Color.gray.opacity(0.1)
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
                            // 매치 카드 (NavigationLink)
                            NavigationLink(destination: MatchDetailView(match: match)) {
                                MatchCardView(match: match)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .overlay(alignment: .topTrailing) {
                                BookmarkButton(
                                    match: match,
                                    isFavorited: favoriteViewModel.isFavorited(matchId: match.id),
                                    action: {
                                        withAnimation {
                                            scrapedMatches.removeAll { $0.id == match.id }
                                        }
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
                    .padding(.bottom, 16)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("찜한 매치")
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if scrapedMatches.isEmpty {
                loadScrapedMatches()
            }
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
                // 중복 제거: id 기준으로 고유한 매치만 남김
                let uniqueMatches = Array(Dictionary(grouping: matches, by: { $0.id })
                    .compactMapValues { $0.first }
                    .values)
                
                self.scrapedMatches = uniqueMatches
                self.isLoading = false
            }
        }
    }
}
