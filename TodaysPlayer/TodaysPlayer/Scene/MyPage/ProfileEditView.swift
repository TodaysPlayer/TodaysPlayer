//  ProfileEditView.swift
//  TodaysPlayer
//
//  Created by J on 9/29/25.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var nickname: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var region: String = ""
    @State private var position: String = "포지션 선택"
    @State private var level: String = "실력 선택"
    @State private var preferredTimes: Set<String> = []
    @State private var intro: String = ""
    @State private var profileImage: Image? = Image("profile_sample")
    
    let positions = ["포지션 선택", "공격수", "미드필더", "수비수", "골키퍼"]
    let levels = ["실력 선택", "입문자", "초급자", "중급자", "상급자"]
    let timeOptions = ["오전", "오후", "저녁", "주말", "평일"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 사진
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            (profileImage ?? Image(systemName: "person.crop.circle.fill"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .background(Circle().fill(Color(.systemGray6)))
                            Button(action: {}) {
                                ZStack {
                                    Circle().fill(Color(.white)).frame(width: 32, height: 32)
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.black)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .offset(x: 4, y: 4)
                        }
                        Text("프로필 사진을 변경하려면 카메라 아이콘을 클릭하세요")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                    
                    // 기본 정보
                    VStack(alignment: .leading, spacing: 16) {
                        Text("기본 정보")
                            .font(.headline)
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("이름").font(.caption).foregroundColor(.gray)
                                TextField("이름", text: $name)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("닉네임").font(.caption).foregroundColor(.gray)
                                TextField("닉네임", text: $nickname)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("연락처").font(.caption).foregroundColor(.gray)
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(.black)
                                TextField("연락처", text: $phone)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("이메일").font(.caption).foregroundColor(.black)
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.black)
                                TextField("이메일", text: $email)
                                    .foregroundColor(.black)
                                    .font(.body)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("거주 지역").font(.caption).foregroundColor(.gray)
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.black)
                                TextField("거주 지역", text: $region)
                                    .foregroundColor(.black)
                                    .font(.body)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                    
                    // 축구/풋살 정보
                    VStack(alignment: .leading, spacing: 16) {
                        Text("축구/풋살 정보")
                            .font(.headline)
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("주 포지션").font(.caption).foregroundColor(.gray)
                                Picker("주 포지션", selection: $position) {
                                    ForEach(positions, id: \.self) { pos in
                                        Text(pos)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("실력 레벨").font(.caption).foregroundColor(.gray)
                                Picker("실력 레벨", selection: $level) {
                                    ForEach(levels, id: \.self) { lv in
                                        Text(lv)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("선호 시간대").font(.caption).foregroundColor(.gray)
                            HStack(spacing: 8) {
                                ForEach(timeOptions, id: \.self) { t in
                                    Button(action: {
                                        if preferredTimes.contains(t) {
                                            preferredTimes.remove(t)
                                        } else {
                                            preferredTimes.insert(t)
                                        }
                                    }) {
                                        Text()
                                            .foregroundColor(preferredTimes.contains(t) ? .white : .black)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                            .background(preferredTimes.contains(t) ? Color(.black) : Color(.systemGray5))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("자기소개").font(.caption).foregroundColor(.gray)
                            TextField("간단한 자기소개를 입력하세요.", text: $intro)
                                .foregroundColor(.black)
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGray5).ignoresSafeArea())
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("저장")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileEditView()
}
