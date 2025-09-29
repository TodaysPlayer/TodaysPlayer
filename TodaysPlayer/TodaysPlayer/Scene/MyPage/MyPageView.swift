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
    @AppStorage("profile_position") private var profilePosition: String = "포지션 선택"
    @AppStorage("profile_level") private var profileLevel: String = "실력 선택"
    
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
                            Image(systemName: "bell")
                                .font(.system(size: 20))
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // 프로필 카드
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 2)
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 74, height: 74)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(profileName.isEmpty ? "프로필 미설정" : profileName)
                                        .font(.system(size: 20, weight: .bold))
                                    Text(profileNickname.isEmpty ? "별명 미설정" : profileNickname)
                                        .font(.system(size: 15, weight: .regular))
                                }
                                HStack(spacing: 10) {
                                    Text(profilePosition)
                                        .font(.caption)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(5)
                                    Text(profileLevel)
                                        .font(.caption)
                                        .padding(.horizontal, 5)
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
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("축구화 할인 특가")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("나이키/아디다스 축구화 최대 30% 할인")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            HStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { i in
                                    Circle()
                                        .fill(i == 0 ? .white : .white.opacity(0.4))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .padding(20)
                        Text("30% OFF")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal,12)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(14)
                            .padding([.top, .trailing], 16)
                    }
                    .frame(height: 108)
                    .padding(.horizontal)

                    // 메뉴 리스트
                    VStack(spacing: 12) {
                        MyPageRowView(icon: "megaphone.fill", iconColor: .blue, title: "앱 공지사항", subtitle: "최신 공지사항 및 업데이트 정보")
                        MyPageRowView(icon: "questionmark.circle.fill", iconColor: .green, title: "운영자에게 문의하기", subtitle: "궁금한 점이나 문제점을 문의하세요")
                        MyPageRowView(icon: "shield.lefthalf.fill", iconColor: .purple, title: "개인정보 처리방침", subtitle: "개인정보 보호 정책 및 이용약관")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemGray5).edgesIgnoringSafeArea(.all))
    }
}

// 통계 뷰
struct StatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold))
            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 1, x: 0, y: 1)
    }
}

// 메뉴 리스트 행 뷰
struct MyPageRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(iconColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.01), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    MyPageView()
}
