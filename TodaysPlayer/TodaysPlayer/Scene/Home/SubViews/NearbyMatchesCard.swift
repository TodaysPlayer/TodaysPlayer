//
//  NearbyMatchesCard.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct NearbyMatchesCard: View {
    @Environment(TabSelection.self) var tabSelection

    let matches: [Match]
    let hasLocationPermission: Bool
    let formatDistance: (Coordinates) -> String
    let onRequestLocationPermission: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            renderContent()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func renderContent() -> some View {
        Group {
            if hasLocationPermission {
                showMatchesList()
            } else {
                showPermissionRequest()
            }
        }
    }
    
    // MARK: - 매치 리스트 표시 (권한 있음)
    @ViewBuilder
    private func showMatchesList() -> some View {
        // 헤더
        HStack {
            Image(systemName: "location.fill")
                .font(.system(size: 16))
                .foregroundStyle(.green)
            
            Text("내 주변 가까운 매치")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        
        // 매치 리스트
        VStack(spacing: 16) {
            if matches.isEmpty {
                Text("주변에 매치가 없습니다")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                    NavigationLink {
                        Text("MatchTitle: \(match.title)")
                    } label: {
                        MatchItemView(
                            title: match.title,
                            location: match.location.name,
                            distance: formatDistance(match.location.coordinates),
                            time: match.dateTime.formatForDisplay(),
                            participants: "\(match.participants.count)/\(match.maxParticipants)",
                            gender: GenderType(rawValue: match.gender) ?? .mixed,
                            rating: nil,
                            price: match.price == 0 ? "무료" : String.formatPrice(match.price),
                            skillLevel: match.skillLevel.skillLevelToKorean(),
                            tags: match.createMatchTags()
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        
        // 더 많은 매치 보기 버튼
        Button(action: {
            tabSelection.selectedTab = 1
        }) {
            Text("더 많은 매치 보기")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - 권한 요청 안내 화면 (권한 없음)
    @ViewBuilder
    private func showPermissionRequest() -> some View {
        VStack(spacing: 20) {
            // 헤더
            HStack {
                Image(systemName: "location.slash")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)
                
                Text("내 주변 가까운 매치")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // 메인 메시지
            VStack(spacing: 12) {
                Text("내 주변 가까운 매치를 찾으려면\n위치 권한이 필요합니다")
                    .font(.system(size: 18))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                
                Text("설정 → 앱 → TodaysPlayer → 위치 → 앱을\n사용하는 동안으로 변경해주세요")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // 권한 허용 버튼
            Button(action: {
                onRequestLocationPermission()
            }) {
                Text("위치 권한 허용하기")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            
            // 보안 안내
            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                Text("위치 정보는 매치 검색에만 사용되며 안전하게 보호됩니다")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
}

#Preview {
    NearbyMatchesCard(
        matches: [],
        hasLocationPermission: true,
        formatDistance: { _ in "1.2km" },
        onRequestLocationPermission: { }
    )
    .environment(TabSelection())
}
