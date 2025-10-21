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
        case 평일, 주말, 오전, 오후, 저녁
    }
    enum Position: String, CaseIterable {
        case 공격수, 미드필더, 수비수, 골키퍼
    }
    enum SkillLevel: String, CaseIterable {
        case 입문자, 초보, 중수, 고수, 쌉고수
    }
    enum Region: String, CaseIterable {
        case 서울, 부산, 대구, 인천, 광주, 대전, 울산, 세종, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주
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

