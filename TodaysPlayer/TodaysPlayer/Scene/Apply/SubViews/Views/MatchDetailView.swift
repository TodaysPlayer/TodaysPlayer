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
    let postedMatchCase: PostedMatchCase = .allMatches
    
    @State private var viewModel: MatchDetailViewModel
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    init(match: Match) {
        self.match = match
        _viewModel = State(initialValue: MatchDetailViewModel(match: match))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MatchTagViewForMatch(match: match, postedMatchCase: .allMatches)
                
                MatchDetailHeaderView(
                    title: match.title,
                    subtitle: "함께 할 플레이어를 모집합니다"
                )
                
                MatchBasicInfoCardForMatch(match: match)
                MatchLocationSectionForMatch(match: match)
                MatchDescriptionSection(description: match.description)
                WarningNoticeView()
                
                OrganizerInfoView(
                    name: "주최자",
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if !viewModel.isMyMatch {
                        favoriteViewModel.toggleFavorite(
                            matchId: match.id,
                            organizerId: match.organizerId
                        )
                    }
                }) {
                    Image(systemName: favoriteViewModel.isFavorited(matchId: match.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.isMyMatch ? .gray : (favoriteViewModel.isFavorited(matchId: match.id) ? .blue : .primary))
                }
                .disabled(viewModel.isMyMatch)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            DynamicMatchActionButton(viewModel: viewModel)
        }
        .onAppear {
            Task {
                await viewModel.refreshUserApplyStatus()
            }
        }
        .task {
            if viewModel.userApplyStatus == .rejected {
                await viewModel.fetchDetailedApply()
            }
        }
    }
}

// MARK: - Match용 태그 뷰
struct MatchTagViewForMatch: View {
    let match: Match
    let postedMatchCase: PostedMatchCase
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(match.matchType == "futsal" ? "풋살" : "축구")
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(match.matchType == "futsal" ? Color.green : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            
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
        let endDate = date.addingTimeInterval(TimeInterval(duration * 60))
        let endTime = formatter.string(from: endDate)
        return "\(startTime)~\(endTime)"
    }
}

// MARK: - Match용 장소 정보 섹션
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
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

// ❌ MatchActionButtonsViewForMatch 삭제됨 (DynamicMatchActionButton으로 대체)
