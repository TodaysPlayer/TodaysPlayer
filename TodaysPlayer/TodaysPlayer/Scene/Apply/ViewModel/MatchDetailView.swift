//
//  MatchDetailView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/12/25.
//

import SwiftUI
import MapKit

// MARK: - 메인 뷰
struct MatchDetailView: View {
    let match: Match
    let postedMatchCase: PostedMatchCase = .allMatches // 기본값
    
    // ✅ FavoriteViewModel 추가
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    // 본인이 작성한 매치인지 확인
    private var isMyMatch: Bool {
        match.organizerId == AuthHelper.currentUserId
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 기존 MatchTagView 재사용 (Match 버전)
                MatchTagViewForMatch(match: match, postedMatchCase: .allMatches)
                
                // 헤더
                MatchDetailHeaderView(
                    title: match.title,
                    subtitle: "함께 할 플레이어를 모집합니다"
                )
                
                // 기본 정보 카드
                MatchBasicInfoCardForMatch(match: match)
                
                // 장소 정보 섹션 (지도 포함)
                MatchLocationSectionForMatch(match: match)
                
                // 설명 섹션
                MatchDescriptionSection(description: match.description)
                
                // 주의사항
                WarningNoticeView()
                
                // 주최자 정보 (임시로 기본값 사용)
                OrganizerInfoView(
                    name: "주최자", // TODO: User 정보 가져오기
                    imageURL: ""
                )
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("매칭 정보")
                    .font(.headline)
            }
            
            // ✅ 북마크 버튼 추가
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if !isMyMatch {
                        favoriteViewModel.toggleFavorite(
                            matchId: match.id,
                            organizerId: match.organizerId
                        )
                    }
                }) {
                    Image(systemName: favoriteViewModel.isFavorited(matchId: match.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isMyMatch ? .gray : (favoriteViewModel.isFavorited(matchId: match.id) ? .blue : .primary))
                }
                .disabled(isMyMatch) // 본인 매치는 비활성화
            }
        }
        .safeAreaInset(edge: .bottom) {
            MatchActionButtonsViewForMatch(
                match: match,
                postedMatchCase: postedMatchCase
            )
        }
    }
}

// MARK: - Match용 태그 뷰
struct MatchTagViewForMatch: View {
    let match: Match
    let postedMatchCase: PostedMatchCase
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 경기 종류 태그
            Text(match.matchType == "futsal" ? "풋살" : "축구")
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(match.matchType == "futsal" ? Color.green : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            
            // 마감 임박 태그
            if match.maxParticipants - match.participants.count == 1 {
                Text("1자리 남음!")
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else if match.participants.count >= match.maxParticipants {
                Text("마감")
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
    }
}

// MARK: - Match용 기본 정보 카드
struct MatchBasicInfoCardForMatch: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                InfoItemView(
                    icon: "calendar",
                    title: "날짜",
                    value: formatDate(match.dateTime)
                )
                
                InfoItemView(
                    icon: "clock",
                    title: "시간",
                    value: formatTime(match.dateTime, duration: match.duration)
                )
            }
            
            Divider()
            
            HStack(spacing: 24) {
                InfoItemView(
                    icon: "person.2",
                    title: "인원",
                    value: "\(match.participants.count)/\(match.maxParticipants)"
                )
                
                InfoItemView(
                    icon: "wonsign.circle",
                    title: "참가비",
                    value: "\(match.price.formatted())원"
                )
            }
            
            Divider()
            
            HStack(spacing: 24) {
                InfoItemView(
                    icon: "person.crop.circle",
                    title: "성별",
                    value: match.genderKorean
                )
                
                InfoItemView(
                    icon: "star.circle",
                    title: "실력",
                    value: skillLevelKorean(match.skillLevel)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // 실력 레벨 한글 변환
    private func skillLevelKorean(_ level: String) -> String {
        switch level.lowercased() {
        case "beginner": return "초급"
        case "intermediate": return "중급"
        case "advanced": return "고급"
        case "expert": return "상급"
        default: return "무관"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date, duration: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startTime = formatter.string(from: date)
        
        // 종료 시간 계산
        let endDate = date.addingTimeInterval(TimeInterval(duration * 60))
        let endTime = formatter.string(from: endDate)
        
        return "\(startTime)~\(endTime)"
    }
}

// MARK: - Match용 장소 정보 섹션 (애플맵 포함)
struct MatchLocationSectionForMatch: View {
    let match: Match
    
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: match.location.coordinates.latitude,
                longitude: match.location.coordinates.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "장소 정보")
            
            VStack(alignment: .leading, spacing: 16) {
                // 구장명
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("구장명")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(match.location.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                // 주소
                HStack(alignment: .top) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("주소")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(match.location.address)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Divider()
                
                // 애플 지도 영역
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 애플 지도
                    Map(position: .constant(MapCameraPosition.region(region))) {
                        Annotation(match.location.name, coordinate: CLLocationCoordinate2D(
                            latitude: match.location.coordinates.latitude,
                            longitude: match.location.coordinates.longitude
                        )) {
                            VStack(spacing: 0) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                                Text(match.location.name)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(4)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}


// MARK: - Match용 하단 버튼
struct MatchActionButtonsViewForMatch: View {
    let match: Match
    let postedMatchCase: PostedMatchCase
    
    private var actionType: MatchActionType {
        postedMatchCase.defaultActionType
    }
    
    // 본인이 작성한 매치인지 확인
    private var isMyMatch: Bool {
        match.organizerId == AuthHelper.currentUserId
    }
    
    var body: some View {
        Group {

// 디버깅용하고 릴리즈용하고 어떻게 나누나
            
#if DEBUG
#warning("버튼 타이틀은 사용자의 신청상태, 사용자가 작성한 글 여부에 따라 변경해주세요 - 추후에 machID도 변경!")
#endif
            let destinationView: AnyView = isMyMatch
            ? AnyView(ParticipantListView(viewModel: ParticipantListViewModel(matchID: "qMRjJMLlVo5N8lgZeLOA")))
            : AnyView(ApplyMatchView(match: match))
//            if isMyMatch {
//                // 본인 매치일 때 - 비활성화된 버튼
//                Text("본인이 작성한 매치입니다")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.gray)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            } else {
//                // 다른 사람 매치일 때 - 신청 가능
            
                NavigationLink(
                    destination: destinationView
                ) {
                    Text(actionType.title)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(actionType.backgroundColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}
