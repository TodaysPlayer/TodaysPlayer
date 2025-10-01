//
//  MyPageView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

// 마이페이지 메인 화면
// - 사용자 프로필 카드, 통계, 배너, 설정/공지 등 메뉴 진입점을 제공합니다.
// - 프로필 편집 화면으로 이동하여 AppStorage에 저장된 정보를 수정할 수 있습니다.
struct MyPageView: View {
    // MARK: - AppStorage (프로필 표시용 데이터)
    // 사용자 이름 (실명)
    @AppStorage("profile_name") private var profileName: String = ""
    // 사용자 닉네임 (별명)
    @AppStorage("profile_nickname") private var profileNickname: String = ""
    // 주 포지션
    @AppStorage("profile_position") private var profilePosition: String = ""
    // 실력 레벨
    @AppStorage("profile_level") private var profileLevel: String = ""
    // 아바타 이미지 Data (선택)
    @AppStorage("profile_avatar") private var avatarData: Data?
    
    // MARK: - State / ViewModel
    // 홈에서 재사용하는 프로모션 배너 뷰모델
    @State private var homeViewModel = HomeViewModel()
    
    // MARK: - Defaults (ProfileEditView와 동일한 기본값)
    private let defaultName: String = "홍길동"
    private let defaultPosition: String = "포지션 선택"
    private let defaultLevel: String = "실력 선택"

    // MARK: - Display (빈 값일 경우 기본값으로 대체)
    private var displayName: String {
        let trimmed = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultName : trimmed
    }
    private var displayPosition: String {
        let trimmed = profilePosition.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultPosition : trimmed
    }
    private var displayLevel: String {
        let trimmed = profileLevel.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultLevel : trimmed
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
        }
    }
    
    // MARK: - Extracted Subviews
    private var header: some View {
        HStack {
            Text("마이페이지")
                .font(.system(size: 26, weight: .bold))
            Spacer()
            HStack(spacing: 20) {
                NavigationLink(destination: NotiView()) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                NavigationLink(destination: SettingView()) {
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
                    if let data = avatarData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
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
                        Text(displayName)
                            .font(.system(size: 20, weight: .bold))
                        Text(profileNickname.isEmpty ? "별명 미설정" : profileNickname)
                            .font(.system(size: 12, weight: .regular))
                    }
                    HStack(spacing: 11.5) {
                        Text(displayPosition)
                            .font(.caption)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(3)
                        Text(displayLevel)
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
        HStack(spacing: 10) {
            StatView(icon: "calendar", value: "5", label: "참여 경기", color: .green)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
            StatView(icon: "chart.line.uptrend.xyaxis", value: "4.8", label: "평균 평점", color: .purple)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
            StatView(icon: "person.3.fill", value: "12", label: "용병 참여", color: .orange)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
    }

    private var bannerSection: some View {
        VStack {
            PromotionalBanner(viewModel: homeViewModel)
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
                MyPageRowView(icon: "megaphone.fill", iconColor: .blue, title: "앱 공지사항", subtitle: "최신 공지사항 및 업데이트 정보")
            }
            NavigationLink(destination: QuestionView()) {
                MyPageRowView(icon: "questionmark.circle.fill", iconColor: .green, title: "운영자에게 문의하기", subtitle: "궁금한 점이나 문제점을 문의하세요")
            }
            NavigationLink(destination: PersonalityView()) {
                MyPageRowView(icon: "shield.lefthalf.fill", iconColor: .purple, title: "개인정보 처리방침", subtitle: "개인정보 보호 정책 및 이용약관")
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
