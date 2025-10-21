//
//  ProfileEditViewModel.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/15/25.
//

import SwiftUI
import PhotosUI
import Combine
import FirebaseFirestore


@MainActor
class ProfileEditViewModel: ObservableObject {
    /// 거주 지역 (자유 입력)
    @AppStorage("profile_region") private var storedRegion: String = ""
    /// 선호 시간대 (콤마로 연결된 문자열, 예: "오전,오후")
    @AppStorage("profile_preferredTimes") private var storedPreferredTimesRaw: String = ""
    /// 자기소개 (자유 입력)
    @AppStorage("profile_intro") private var storedIntro: String = ""
    /// 프로필 아바타 이미지 데이터 (JPEG/PNG Data)
    @AppStorage("profile_avatar") private var storedAvatarData: Data?
    
    @AppStorage("profile_position") private var storedPosition: String = ""
    
    @AppStorage("profile_level") private var storedLevel: String = ""
    
    // MARK: - Editing State (화면에서 편집 중인 값)
    @Published var editIntro: String = ""
    @Published var editAvatarData: Data?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published private(set) var didLoad: Bool = false
    
    @Published var region: Region = .서울
    @Published var position: Position = .공격수
    @Published var level: SkillLevel = .입문자
    @Published var preferredTimes: Set<TimeOption> = []
    
    // MARK: - Options
    enum TimeOption: String, CaseIterable {
        case 평일
        case 주말
        case 오전
        case 오후
        case 저녁
    }
    enum Position: String, CaseIterable {
        case 공격수
        case 미드필더
        case 수비수
        case 골키퍼
    }
    enum SkillLevel: String, CaseIterable {
        case 입문자
        case 초보
        case 중수
        case 고수
        case 쌉고수
    }
    enum Region: String, CaseIterable {
        case 서울
        case 부산
        case 대구
        case 인천
        case 광주
        case 대전
        case 울산
        case 세종
        case 경기
        case 강원
        case 충북
        case 충남
        case 전북
        case 전남
        case 경북
        case 경남
        case 제주
    }
    
    // MARK: - Load / Save
    func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        // 편집용 상태로 복사
        editIntro = storedIntro
        editAvatarData = storedAvatarData
        
        if let r = Region(rawValue: storedRegion), !storedRegion.isEmpty {
            region = r
        } else {
            region = .서울
        }
        
        let rawSet = storedPreferredTimesRaw.split(separator: ",").map { String($0) }
        preferredTimes = Set(rawSet.compactMap { TimeOption(rawValue: $0) })
    }
    
    func save() {
        // 편집 내용을 AppStorage로 반영
        storedPosition = position.rawValue
        storedLevel = level.rawValue
        storedIntro = editIntro
        storedAvatarData = editAvatarData
        storedRegion = region.rawValue
        storedPreferredTimesRaw = preferredTimes.map { $0.rawValue }.sorted().joined(separator: ",")
        saveToFirebase(position: position, level: level)
    }
    
    private func saveToFirebase(position: Position, level: SkillLevel) {
        guard let uid = UserSessionManager.shared.currentUser?.id else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        let data: [String: Any] = [
            "position": position.rawValue,
            "level": level.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        Task {
            do {
                try await docRef.setData(data, merge: true)
            } catch {
                #if DEBUG
                print("Failed to update Firebase profile: \(error)")
                #endif
            }
        }
    }
    
    func togglePreferredTime(_ t: TimeOption) {
        withAnimation {
            if preferredTimes.contains(t) {
                preferredTimes.remove(t)
            } else {
                preferredTimes.insert(t)
            }
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

