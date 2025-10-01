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
    private let defaultPosition: String = "포지션"
    private let defaultLevel: String = "실력"

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
        // MARK: - UI
        // 전체 화면 내비게이션 컨테이너
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더(타이틀, 알림/설정 이동)
                    // 상단 네비게이션
                    HStack {
                        Text("마이페이지")
                            .font(.system(size: 26, weight: .bold))
                        Spacer()
                        HStack(spacing: 20) {
                            NavigationLink(destination: NotiView()) {
                                Image(systemName: "bell")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(.black))
                            }
                            NavigationLink(destination: SettingView()) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(.black))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // 사용자 프로필 카드 (이름/닉네임/포지션/레벨, 편집 이동)
                    // 프로필 카드
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                        HStack(alignment: .center, spacing: 10) {
                            // 저장된 아바타가 있으면 표시, 없으면 기본 아이콘
                            Group {
                                if let data = avatarData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
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
                                        .background(Color(.systemGray4))
                                        .cornerRadius(3)
                                    Text(displayLevel)
                                        .font(.caption)
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray4))
                                        .cornerRadius(3)
                                }
                            }
                            Spacer()
                            // 프로필 편집 화면으로 이동
                            NavigationLink(destination: ProfileEditView()) {
                                Text("프로필 편집")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            }
                        }
                        .padding(20)
                    }
                    .frame(height: 120)
                    .padding(.horizontal)

                    // 사용자 활동 통계 (이번달 경기 수, 평균 평점, 용병 참여 수)
                    // 3개 통계 카드 (화이트 카드 + 그림자)
                        HStack(spacing: 10) {
                            StatView(icon: "calendar", value: "5", label: "참여 경기", color: .green)
                            StatView(icon: "chart.line.uptrend.xyaxis", value: "4.8", label: "평균 평점", color: .purple)
                            StatView(icon: "person.3.fill", value: "12", label: "용병 참여", color: .orange)
                        }
                            .frame(width: 330, height: 150)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                            .padding(.horizontal)

                    // 프로모션/공지 배너 (화이트 카드 + 그림자)

                        PromotionalBanner(viewModel: homeViewModel)
                            .padding(15)

                    // 공지/문의/개인정보 처리방침 등 메뉴 목록
                    // 메뉴 리스트 (화이트 카드 + 그림자)
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.gray))
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
                        .foregroundStyle(Color(.black))
                        .padding(16)
                    }
                }
            }
        }
        .background(Color(.systemGray).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    MyPageView()
}
