//
//  MyPageView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import FirebaseAuth

// 마이페이지 메인 화면
// - 사용자 프로필 카드, 통계, 배너, 설정/공지 등 메뉴 진입점을 제공합니다.
// - 프로필 편집 화면으로 이동하여 AppStorage에 저장된 정보를 수정할 수 있습니다.
struct MyPageView: View {
    // MARK: - State / ViewModel
    // 홈에서 재사용하는 프로모션 배너 뷰모델
    @State private var homeViewModel = HomeViewModel()
    @State private var notifications: [String] = []
    @State private var viewModel = MyPageViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView().padding(.bottom, 8)
                    }
                    if let error = viewModel.errorMessage {
                        Text(error).font(.caption).foregroundStyle(.red)
                    }
                    header
                    profileCard
                    statsRow
                    bannerSection
                    menuList
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .background(Color.gray.opacity(0.1))
            .task {
                await viewModel.load()
            }
        }
    }
    
    // MARK: - Extracted Subviews
    private var header: some View {
        HStack {
            Text("마이페이지")
                .font(.system(size: 26, weight: .bold))
            Spacer()
            HStack(spacing: 20) {
                NavigationLink(destination: NotiView(notifications: $notifications)) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                NavigationLink(destination: AccountView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
            }
        }
        .padding(.top, 8)
    }

    private var profileCard: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                Group {
                    if let urlString = viewModel.profile.avatarURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Image(systemName: "person.crop.circle.fill").resizable().scaledToFill().foregroundStyle(Color.green)
                            @unknown default:
                                Image(systemName: "person.crop.circle.fill").resizable().scaledToFill().foregroundStyle(Color.green)
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundStyle(Color.green)
                    }
                }
                .frame(width: 75, height: 75)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text((viewModel.profile.nickname ?? "").isEmpty ? "별명 미설정" : (viewModel.profile.nickname ?? ""))
                            .font(.system(size: 20, weight: .bold))
                    }
                    HStack(spacing: 11.5) {
                        Text(viewModel.profile.displayPosition)
                            .font(.caption)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(3)
                        Text(viewModel.profile.displayLevel)
                            .font(.caption)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(3)
                    }
                }
                Spacer()
                NavigationLink(destination: ProfileEditView()) {
                    Text("프로필 편집")
                        .foregroundStyle(Color(.green))
                        .font(.system(size: 11.5, weight: .medium))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(7)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack {
            NavigationLink(destination: MatchListView()) {
                Stat(icon: "calendar", label: "신청한 경기", color: .green)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            }

            NavigationLink(
                destination: MyRatingView(viewModel: MyRatingViewModel())
            ) {
                Stat(icon: "chart.line.uptrend.xyaxis", label: "나의 평점", color: .green.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            }
            
            NavigationLink(destination: ScrapView()) {
                Stat(icon: "bookmark.fill", label: "경기 스크랩", color: .cyan.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            }
        }
        .foregroundStyle(Color(.label))
    }

    private var bannerSection: some View {
        VStack {
            PromotionalBanner(bannerData: homeViewModel.bannerData)
                .frame(maxWidth: .infinity)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var menuList: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: AnnouncementView()) {
                MyPageRow(icon: "megaphone.fill", iconColor: .blue, title: "앱 공지사항", subtitle: "최신 공지사항 및 업데이트 정보")
            }
            NavigationLink(destination: QuestionView()) {
                MyPageRow(icon: "questionmark.circle.fill", iconColor: .green, title: "운영자에게 문의하기", subtitle: "궁금한 점이나 문제점을 문의하세요")
            }
            NavigationLink(destination: PersonalityView()) {
                MyPageRow(icon: "shield.lefthalf.fill", iconColor: .purple, title: "개인정보 처리방침", subtitle: "개인정보 보호 정책 및 이용약관")
            }
        }
        .padding(7)
        .foregroundStyle(.black)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    MyPageView()
}

