//  ProfileEditView.swift
//  TodaysPlayer
//
//  Created by J on 9/29/25.
//

import SwiftUI
import PhotosUI

/// 프로필 편집 화면
/// - AppStorage에 저장된 사용자 프로필 정보를 읽어와 화면에서 편집하고, 저장 버튼으로 다시 반영합니다.
/// - 사진은 PhotosPicker를 통해 선택하며, 선택한 이미지는 `Data`로 임시 보관 후 저장 시 반영됩니다.
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - AppStorage (영구 저장되는 사용자 프로필 값)
    // MARK: - Auth Info (로그인 계정에서 제공)
    /// 로그인 계정 이름 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_name") private var authName: String = ""
    /// 로그인 계정 연락처 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_phone") private var authPhone: String = ""
    /// 로그인 계정 이메일 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_email") private var authEmail: String = ""
    
    /// 이름 (로그인 정보에서 자동 채움, 읽기 전용)
    @AppStorage("profile_name") private var name: String = "홍길동"
    /// 닉네임 (표시용 별명)
    @AppStorage("profile_nickname") private var nickname: String = ""
    /// 연락처 (로그인 정보에서 자동 채움, 읽기 전용)
    @AppStorage("profile_phone") private var phone: String = ""
    /// 이메일 (로그인 정보에서 자동 채움, 읽기 전용)
    @AppStorage("profile_email") private var email: String = ""
    /// 거주 지역 (자유 입력)
    @AppStorage("profile_region") private var region: String = ""
    /// 주 포지션 (선택 항목)
    @AppStorage("profile_position") private var position: String = ""
    /// 실력 레벨 (선택 항목)
    @AppStorage("profile_level") private var level: String = ""
    /// 선호 시간대 (콤마로 연결된 문자열, 예: "오전,오후")
    @AppStorage("profile_preferredTimes") private var preferredTimesRaw: String = ""
    /// 자기소개 (자유 입력)
    @AppStorage("profile_intro") private var intro: String = ""
    /// 프로필 아바타 이미지 데이터 (JPEG/PNG Data)
    @AppStorage("profile_avatar") private var avatarData: Data?
    
    // MARK: - Editing State (화면에서 편집 중인 값)
    @State private var editNickname: String = ""
    @State private var editRegion: String = ""
    @State private var editPosition: String = ""
    @State private var editLevel: String = ""
    @State private var editPreferredTimesRaw: String = ""
    @State private var editIntro: String = ""
    @State private var didLoad: Bool = false
    @State private var editAvatarData: Data?
    @State private var bodyText: String = ""
    /// PhotosPicker에서 선택한 항목 (이미지 선택 결과)
    @State private var selectedPhotoItem: PhotosPickerItem?

    // MARK: - Options
    /// 선호 시간대 옵션 목록
    private var timeOptions: [String] { ["평일", "주말", "오전", "오후", "저녁"] }
    /// 포지션 옵션 목록
    private var positions: [String] { ["공격수", "미드필더", "수비수", "골키퍼"] }
    /// 실력 레벨 옵션 목록
    private var levels: [String] { ["입문자", "초급자", "중급자", "상급자"] }
    
    // MARK: - Defaults (입력값이 없을 때 사용되는 기본값)
    private let defaultName: String = "홍길동"
    private let defaultPhone: String = "010-1234-5678"
    private let defaultEmail: String = "sample@sample.com"
    
    /// 편집 중인 선호 시간대의 집합 표현 (콤마 구분 문자열을 Set으로 변환)
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
                                    .foregroundStyle(Color(.green))
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray6)))
                        // 프로필 사진 선택 버튼 (이미지 선택 시 selectedPhotoItem이 업데이트됨)
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            ZStack {
                                Circle().fill(Color(.white)).frame(width: 32, height: 32)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                    Text("프로필 사진을 변경하려면 카메라 아이콘을 클릭하세요.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.white)))
                
                // 기본 정보
                VStack(alignment: .leading, spacing: 16) {
                    Text("기본 정보")
                        .font(.headline)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("이름").font(.caption).foregroundColor(.gray)
                            TextField("이름", text: $name)
                                .padding(5.5)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
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
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.white)))
                
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
                            .frame(maxWidth: .infinity, alignment: .center)
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
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("선호 시간대").font(.caption).foregroundColor(.gray)
                        HStack(spacing: 5) {
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
                                        .padding(.horizontal, 12)
                                        .background(editPreferredTimes.contains(t) ? Color(.green) : Color(.systemGray5))
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
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.white)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
        .navigationTitle("프로필 편집")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // 입력값을 영구 저장소(AppStorage)에 반영하고 화면을 닫습니다.
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
        // 화면 최초 진입 시, 저장된 값을 편집용 상태로 로드 (한 번만 실행)
        .onAppear {
            // 저장된 프로필 값을 편집용 상태 변수들로 복사
            if !didLoad {
                // 로그인 계정 정보로 이름/연락처/이메일을 자동 채움 (값이 있으면 덮어씀)
                if !authName.isEmpty { name = authName }
                if !authPhone.isEmpty { phone = authPhone }
                if !authEmail.isEmpty { email = authEmail }
                // 로그인 정보가 없어 비어있는 경우, 기본값으로 채움
                if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { name = defaultName }
                if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { phone = defaultPhone }
                if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { email = defaultEmail }

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
        // 사용자가 사진을 선택할 때마다 호출되어, 선택된 이미지를 Data로 로드
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
