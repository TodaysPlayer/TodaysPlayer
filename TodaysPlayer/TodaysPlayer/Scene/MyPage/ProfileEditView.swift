//  ProfileEditView.swift
//  TodaysPlayer
//
//  Created by J on 9/29/25.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profile_name") private var name: String = ""
    @AppStorage("profile_nickname") private var nickname: String = ""
    @AppStorage("profile_phone") private var phone: String = ""
    @AppStorage("profile_email") private var email: String = ""
    @AppStorage("profile_region") private var region: String = ""
    @AppStorage("profile_position") private var position: String = "포지션 선택"
    @AppStorage("profile_level") private var level: String = "실력 선택"
    @AppStorage("profile_preferredTimes") private var preferredTimesRaw: String = ""
    @AppStorage("profile_intro") private var intro: String = ""
    
    private var timeOptions: [String] { ["오전", "오후", "저녁", "주말", "평일"] }
    private var positions: [String] { ["포지션 선택", "공격수", "미드필더", "수비수", "골키퍼"] }
    private var levels: [String] { ["실력 선택", "입문자", "초급자", "중급자", "상급자"] }
    
    private var preferredTimes: Set<String> {
        Set(preferredTimesRaw.split(separator: ",").map { String($0) }.filter { !$0.isEmpty })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 사진
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.crop.circle.fill")
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
                                .disabled(true)
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
                                .foregroundColor(.black)
                                .font(.body)
                                .disabled(true)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("이메일").font(.caption).foregroundColor(.gray)
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.black)
                            TextField("이메일", text: $email)
                                .foregroundColor(.black)
                                .font(.body)
                                .disabled(true)
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
                                    var new = preferredTimes
                                    if new.contains(t) {
                                        new.remove(t)
                                    } else {
                                        new.insert(t)
                                    }
                                    preferredTimesRaw = new.sorted().joined(separator: ",")
                                }) {
                                    Text(t)
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
                            .textFieldStyle(.roundedBorder)
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

#Preview {
    ProfileEditView()
}
