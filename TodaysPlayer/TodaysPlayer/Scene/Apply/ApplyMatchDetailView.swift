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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 기존 MatchTagView 재사용
                MatchTagView(matchInfo: matchInfo, postedMatchCase: .allMatches)
                
                // 헤더
                MatchDetailHeaderView(
                    title: matchInfo.matchTitle,
                    subtitle: "함께 할 플레이어를 모집합니다"
                )
                
                // 기본 정보 카드
                MatchBasicInfoCard(matchInfo: matchInfo)
                
                // 상세 정보 섹션
                MatchDetailInfoSection(matchInfo: matchInfo)
                
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("매칭 정보")
                    .font(.headline)
            }
        }
        .safeAreaInset(edge: .bottom) {
            MatchActionButtonsView(matchInfo: matchInfo)
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
        }
        .padding()
        .background(Color(.systemBackground))
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

// MARK: - 상세 정보 섹션
struct MatchDetailInfoSection: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "상세 정보")
            
            DetailRowView(
                icon: "mappin.circle",
                label: "매치 장소",
                value: matchInfo.matchLocation
            )
            
            DetailRowView(
                icon: "figure.soccer",
                label: "매치 종류",
                value: matchInfo.matchType.displayName
            )
            
            DetailRowView(
                icon: "person.crop.circle",
                label: "성별 제한",
                value: matchInfo.genderLimit
            )
            
            DetailRowView(
                icon: "star.circle",
                label: "레벨 제한",
                value: matchInfo.levelLimit
            )
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

// MARK: - 상세 정보 행
struct DetailRowView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
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
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("준비물:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("• 풋살화 (축구화 권장)\n• 개인 음료\n• 수건")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - 하단 버튼 (참여신청하기)
struct MatchActionButtonsView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        NavigationLink(
            destination: ApplyMatchView()
        ) {
            Text("참여신청하기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
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
