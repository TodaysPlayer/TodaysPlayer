//  ProfileEditView.swift
//  TodaysPlayer
//
//  Created by J on 9/29/25.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profile_name") private var name: String = ""
    @AppStorage("profile_nickname") private var nickname: String = ""
    @AppStorage("profile_phone") private var phone: String = ""
    @AppStorage("profile_email") private var email: String = ""
    @AppStorage("profile_region") private var region: String = ""
    @AppStorage("profile_position") private var position: String = "포지션"
    @AppStorage("profile_level") private var level: String = "실력"
    @AppStorage("profile_preferredTimes") private var preferredTimesRaw: String = ""
    @AppStorage("profile_intro") private var intro: String = ""
    @AppStorage("profile_avatar") private var avatarData: Data?
    
    @State private var editNickname: String = ""
    @State private var editRegion: String = ""
    @State private var editPosition: String = ""
    @State private var editLevel: String = ""
    @State private var editPreferredTimesRaw: String = ""
    @State private var editIntro: String = ""
    @State private var didLoad: Bool = false
    @State private var editAvatarData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?

    private var timeOptions: [String] { ["오전", "오후", "저녁", "주말", "평일"] }
    private var positions: [String] { ["포지션", "공격수", "미드필더", "수비수", "골키퍼"] }
    private var levels: [String] { ["실력", "입문자", "초급자", "중급자", "상급자"] }
    
    private var editPreferredTimes: Set<String> {
        Set(editPreferredTimesRaw.split(separator: ",").map { String($0) }.filter { !$0.isEmpty })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 사진
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let data = editAvatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray6)))
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
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
                                .padding(5.5)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5)))
                                .font(.body)
                                .disabled(true)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("닉네임").font(.caption).foregroundColor(.gray)
                            TextField("닉네임", text: $editNickname)
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
                            TextField("거주 지역", text: $editRegion)
                                .foregroundColor(.black)
                                .font(.body)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.white)))
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
                            Picker("주 포지션", selection: $editPosition) {
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
                            Picker("실력 레벨", selection: $editLevel) {
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
                                    var new = editPreferredTimes
                                    if new.contains(t) {
                                        new.remove(t)
                                    } else {
                                        new.insert(t)
                                    }
                                    editPreferredTimesRaw = new.sorted().joined(separator: ",")
                                }) {
                                    Text(t)
                                        .foregroundColor(editPreferredTimes.contains(t) ? .white : .black)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 14)
                                        .background(editPreferredTimes.contains(t) ? Color(.black) : Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("자기소개").font(.caption).foregroundColor(.gray)
                        TextField("간단한 자기소개를 입력하세요.", text: $editIntro)
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
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("프로필 편집")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    nickname = editNickname
                    region = editRegion
                    position = editPosition
                    level = editLevel
                    preferredTimesRaw = editPreferredTimesRaw
                    intro = editIntro
                    avatarData = editAvatarData
                    dismiss()
                }) {
                    Text("저장")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
            }
        }
        .onAppear {
            if !didLoad {
                editAvatarData = avatarData
                editNickname = nickname
                editRegion = region
                editPosition = position
                editLevel = level
                editPreferredTimesRaw = preferredTimesRaw
                editIntro = intro
                didLoad = true
            }
        }
        .onChange(of: selectedPhotoItem) {
            guard let newItem = selectedPhotoItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    editAvatarData = data
                }
            }
        }
    }
}

#Preview {
    ProfileEditView()
}
