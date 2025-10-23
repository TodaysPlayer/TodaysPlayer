//
//  DynamicMatchActionButton.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/17/25.
//

import SwiftUI

struct DynamicMatchActionButton: View {
    @Bindable var viewModel: MatchDetailViewModel
    @State private var navigateToApply = false
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            Group {
                if viewModel.isMyMatch {
                    // 본인 매치 - 참여자 관리
                    NavigationLink(
                        destination: ParticipantListView(
                            viewModel: ParticipantListViewModel(match: viewModel.match)
                        )
                    ) {
                        buttonLabel
                    }
                } else if viewModel.userApplyStatus == nil {
                    // 신청 안함 - 신청하기 (Button으로 변경)
                    Button {
                        viewModel.handleApplyButtonTap()
                        if viewModel.canUserApply() {
                            navigateToApply = true
                        }
                    } label: {
                        buttonLabel
                    }
                    .background(
                        NavigationLink(
                            destination: ApplyMatchView(match: viewModel.match),
                            isActive: $navigateToApply
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )
                } else {
                    // 신청 완료 상태 - 비활성화된 버튼만 표시
                    buttonLabel
                        .opacity(0.7)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private var buttonLabel: some View {
        Text(viewModel.buttonTitle)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.isButtonEnabled ?
                viewModel.buttonBackgroundColor :
                Color.gray.opacity(0.5)
            )
            .cornerRadius(12)
    }
}

#Preview {
    DynamicMatchActionButton(
        viewModel: MatchDetailViewModel(
            match: Match(
                id: "preview",
                title: "주말 풋살 매치",
                description: "함께 즐거운 경기 해요!",
                organizerId: "user123",
                organizerName: "미드필더박영희",
                organizerProfileURL: "",
                teamId: nil,
                matchType: "futsal",
                gender: "mixed",
                location: MatchLocation(
                    name: "성북 풋살파크",
                    address: "서울특별시 성북구",
                    coordinates: Coordinates(latitude: 37.5, longitude: 127.0)
                ),
                dateTime: Date(),
                duration: 120,
                maxParticipants: 12,
                skillLevel: "beginner",
                position: nil,
                price: 5000,
                rating: nil,
                status: "recruiting",
                tags: [],
                requirements: nil,
                participants: [:],
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    )
}
