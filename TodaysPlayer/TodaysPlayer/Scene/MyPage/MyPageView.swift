//
//  MyPageView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MyPageView: View {
    @AppStorage("profile_name") private var profileName: String = ""
    @AppStorage("profile_nickname") private var profileNickname: String = ""
    @AppStorage("profile_position") private var profilePosition: String = ""
    @AppStorage("profile_level") private var profileLevel: String = ""
    @AppStorage("profile_avatar") private var avatarData: Data?
    @State private var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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

                    // 프로필 카드
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                        HStack(alignment: .center, spacing: 16) {
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
                            .frame(width: 74, height: 74)
                            .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(profileName)
                                        .font(.system(size: 20, weight: .bold))
                                    Text(profileNickname.isEmpty ? "별명 미설정" : profileNickname)
                                        .font(.system(size: 15, weight: .regular))
                                }
                                HStack(spacing: 11.5) {
                                    Text(profilePosition)
                                        .font(.caption)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(5)
                                    Text(profileLevel)
                                        .font(.caption)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(5)
                                }
                            }
                            Spacer()
                            NavigationLink(destination: ProfileEditView()) {
                                Text("프로필 편집")
                                    .font(.system(size: 15, weight: .medium))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            }
                        }
                        .padding(20)
                    }
                    .frame(height: 120)
                    .padding(.horizontal)

                    // 3개 통계 카드
                    HStack(spacing: 16) {
                        StatView(icon: "calendar", value: "5", label: "이번달 경기", color: .green)
                        StatView(icon: "chart.line.uptrend.xyaxis", value: "4.8", label: "평균 평점", color: .purple)
                        StatView(icon: "person.3.fill", value: "12", label: "용병 참여", color: .orange)
                    }
                    .padding(.horizontal)

                    // 배너
                    PromotionalBanner(viewModel: homeViewModel)

                    // 메뉴 리스트
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
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemGray5).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    MyPageView()
}

