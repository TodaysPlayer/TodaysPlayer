//
//  ApplyMatchDetailView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/29/25.
//

import SwiftUI

// MARK: - 메인 뷰
struct ApplyMatchDetailView: View {
    let matchInfo: MatchInfo
    let postedMatchCase: PostedMatchCase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 기존 MatchTagView 재사용
                MatchTagView(info: matchInfo, matchCase: .allMatches)
                
                // 헤더
                MatchDetailHeaderView(
                    title: matchInfo.matchTitle,
                    subtitle: "함께 할 플레이어를 모집합니다"
                )
                
                // 기본 정보 카드
                MatchBasicInfoCard(matchInfo: matchInfo)
                
                // 장소 정보 섹션 (새로 추가)
                MatchLocationSection(matchInfo: matchInfo)
                
                // 설명 섹션
                MatchDescriptionSection(description: matchInfo.matchDescription)
                
                // 주의사항
                WarningNoticeView()
                
                // 주최자 정보
                OrganizerInfoView(
                    name: matchInfo.postUserName,
                    imageURL: matchInfo.imageURL
                )
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGray6)) // 배경색을 옅은 회색으로 변경
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("매칭 정보")
                    .font(.headline)
            }
        }
        .safeAreaInset(edge: .bottom) {
            MatchActionButtonsView(
                matchInfo: matchInfo,
                postedMatchCase: postedMatchCase
            )
        }
    }
}

// MARK: - 헤더 컴포넌트
struct MatchDetailHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 기본 정보 카드
struct MatchBasicInfoCard: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                InfoItemView(
                    icon: "calendar",
                    title: "날짜",
                    value: formatDate(matchInfo.matchTime)
                )
                
                InfoItemView(
                    icon: "clock",
                    title: "시간",
                    value: formatTime(matchInfo.matchTime)
                )
            }
            
            Divider()
            
            HStack(spacing: 24) {
                InfoItemView(
                    icon: "person.2",
                    title: "인원",
                    value: "\(matchInfo.applyCount)/\(matchInfo.maxCount)"
                )
                
                InfoItemView(
                    icon: "wonsign.circle",
                    title: "참가비",
                    value: "\(matchInfo.matchFee.formatted())원"
                )
            }
            
            Divider()
            
            HStack(spacing: 24) {
                InfoItemView(
                    icon: "person.crop.circle",
                    title: "성별",
                    value: matchInfo.genderLimit
                )
                
                InfoItemView(
                    icon: "star.circle",
                    title: "실력",
                    value: matchInfo.levelLimit
                )
            }
        }
        .padding()
        .background(Color(.systemBackground)) // 흰색 유지
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        // ISO8601 등 서버 날짜 형식에 맞게 파싱
        // 예: "12월 29일"
        return "12월 29일" // 실제로는 파싱 로직 추가
    }
    
    private func formatTime(_ dateString: String) -> String {
        // 예: "19:00-21:00"
        return "19:00-21:00" // 실제로는 파싱 로직 추가
    }
}

// MARK: - 정보 아이템 (재사용)
struct InfoItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 장소 정보 섹션 (새로 추가)
struct MatchLocationSection: View {
    let matchInfo: MatchInfo
    
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
                        
                        Text(matchInfo.matchLocation)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                // 주소 (임시 - 서버에서 받아올 예정)
                HStack(alignment: .top) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("주소")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("서울시 강남구 논현동 123-45")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Divider()
                
                // 지도 영역 (애플 지도 추가 예정)
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 지도 플레이스홀더
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(height: 200)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("지도가 여기에 표시됩니다")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground)) // 흰색으로 변경
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - 설명 섹션
struct MatchDescriptionSection: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "설명")
            
            Text(description)
                .font(.body)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground)) // 흰색으로 변경
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - 섹션 헤더
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
}

// MARK: - 주의사항
struct WarningNoticeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "주의사항")
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("날씨가 좋지 않을 경우에만 매칭 취소 예외입니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - 주최자 정보
struct OrganizerInfoView: View {
    let name: String
    let imageURL: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "주최자 정보")
            
            HStack(spacing: 12) {
                // 프로필 이미지 (AsyncImage 사용)
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("매칭 주최자입니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground)) // 흰색으로 변경
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - 하단 버튼 (참여신청하기)
struct MatchActionButtonsView: View {
    let matchInfo: MatchInfo
    let postedMatchCase: PostedMatchCase
        
    private var actionType: MatchActionType {
        postedMatchCase.defaultActionType
    }
    
    var body: some View {
        NavigationLink {
            switch postedMatchCase {
            case .allMatches:
                ApplyMatchView()
            case .appliedMatch:
                ApplyMatchView()    // 신청 못하게 막기
            case .myRecruitingMatch:
                ParticipantListView(viewModel: ParticipantListViewModel(matchID: matchInfo.matchId))
            case .finishedMatch:
                ApplyMatchView()    // 신청 못하게 막기
            }
        } label: {
            Text(actionType.title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(actionType.backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)

//        NavigationLink(
//            destination: ApplyMatchView()
//        ) {
//            Text(actionType.title)
//                .font(.headline)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(actionType.backgroundColor)
//                .foregroundColor(.white)
//                .cornerRadius(12)
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

// MARK: - MatchType Extension (표시용)
extension MatchType {
    var displayName: String {
        switch self {
        case .futsal:
            return "풋살"
        case .soccer:
            return "축구"
        }
    }
}
