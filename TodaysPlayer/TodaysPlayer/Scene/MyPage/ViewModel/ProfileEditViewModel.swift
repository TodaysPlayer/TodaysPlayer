//
//  ProfileEditViewModel.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/15/25.
//

import SwiftUI
import PhotosUI
import Combine


class ProfileEditViewModel: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    // MARK: - Auth Info (로그인 계정에서 제공)
    /// 로그인 계정 이름 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_name") var authName: String = ""
    /// 로그인 계정 연락처 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_phone") var authPhone: String = ""
    /// 로그인 계정 이메일 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_email") var authEmail: String = ""
    /// 로그인 계정 성별 (읽기 전용, 로그인 과정에서 설정)
    @AppStorage("auth_gender") var authGender: String = ""
    
    /// 닉네임 (표시용 별명)
    @AppStorage("profile_nickname") private var storedNickname: String = ""
    /// 거주 지역 (자유 입력)
    @AppStorage("profile_region") private var storedRegion: String = ""
    /// 주 포지션 (선택 항목)
    @AppStorage("profile_position") private var storedPosition: String = ""
    /// 실력 레벨 (선택 항목)
    @AppStorage("profile_level") private var storedLevel: String = ""
    /// 선호 시간대 (콤마로 연결된 문자열, 예: "오전,오후")
    @AppStorage("profile_preferredTimes") private var storedPreferredTimesRaw: String = ""
    /// 자기소개 (자유 입력)
    @AppStorage("profile_intro") private var storedIntro: String = ""
    /// 프로필 아바타 이미지 데이터 (JPEG/PNG Data)
    @AppStorage("profile_avatar") private var storedAvatarData: Data?
    
    // MARK: - Editing State (화면에서 편집 중인 값)
    @Published var editNickname: String = ""
    @Published var editIntro: String = ""
    @Published var editAvatarData: Data?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published private(set) var didLoad: Bool = false
    
    @Published var region: String = ""
    @Published var position: String = ""
    @Published var level: String = ""
    @Published var preferredTimes: Set<String> = []
    
    // MARK: - Options
    let timeOptions: [String] = ["평일", "주말", "오전", "오후", "저녁"]
    let positions: [String] = ["공격수", "미드필더", "수비수", "골키퍼"]
    let levels: [String] = ["입문자", "초급자", "중급자", "상급자"]
    let regions: [String] = ["서울","부산","대구","인천","광주","대전","울산","세종","경기도","강원도","충북","충남도","전북","전남","경북","경남","제주"]
    
    // MARK: - Defaults (입력값이 없을 때 사용되는 기본값)
    let defaultName: String = "홍길동"
    let defaultPhone: String = "010-1234-5678"
    let defaultEmail: String = "sample@sample.com"
    let defaultGender: String = "남성"
    
    // MARK: - Load / Save
    func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        // 편집용 상태로 복사
        editNickname = storedNickname
        editIntro = storedIntro
        editAvatarData = storedAvatarData
        region = storedRegion
        position = storedPosition
        level = storedLevel
        preferredTimes = Set(storedPreferredTimesRaw.split(separator: ",").map { String($0) }.filter { !$0.isEmpty })
    }
    
    func save() {
        // 편집 내용을 AppStorage로 반영
        storedNickname = editNickname
        storedIntro = editIntro
        storedAvatarData = editAvatarData
        storedRegion = region
        storedPosition = position
        storedLevel = level
        storedPreferredTimesRaw = preferredTimes.sorted().joined(separator: ",")
    }
    
    func togglePreferredTime(_ t: String) {
        if preferredTimes.contains(t) {
            preferredTimes.remove(t)
        } else {
            preferredTimes.insert(t)
        }
    }
    
    // MARK: - Photos
    @MainActor
    func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.editAvatarData = data
            }
        } catch {
            // 실패 시 무시하거나 로깅
            #if DEBUG
            print("Failed to load photo data: \(error)")
            #endif
        }
    }
}

