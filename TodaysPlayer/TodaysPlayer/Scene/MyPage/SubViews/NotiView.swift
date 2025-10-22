//
//  NotiView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import FirebaseFirestore

struct NotiView: View {
    // 주입 가능한 알림 데이터. 바인딩으로 받아 삭제가 반영됩니다.
    @Binding var notifications: [String]
    var onSelectMatch: (String) -> Void = { _ in }
    @State private var messageToDocId: [String: String] = [:]
    @State private var processedKeys: Set<String> = []
    
    @State private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 16) {
            // 내용
            if notifications.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("매칭진행 / 완료 등등 \n알람이 이곳에 표시됩니다!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(notifications, id: \.self) { message in
                        Button {
                            if let docId = messageToDocId[message] {
                                onSelectMatch(docId)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "bell")
                                    .foregroundColor(.blue)
                                Text(message)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let message = notifications[index]
                            notifications.remove(at: index)
                            messageToDocId.removeValue(forKey: message)
                        }
                        persistNotifications()
                        persistMessageDocMap()
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(.title2)
                    .bold()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    notifications.removeAll()
                    messageToDocId.removeAll()
                    persistNotifications()
                    persistMessageDocMap()
                }) {
                    Image(systemName: "bell.slash")
                }
                .accessibilityLabel("모든 알림 삭제")
                .disabled(notifications.isEmpty)
                .tint(.red)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // 시트(아래에서 올라오는 모달) 표현 설정
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .background(Color.gray.opacity(0.1))
        .onAppear {
            loadStoredNotifications()
            loadProcessedKeys()
            loadMessageDocMap()
            startListeningApplyStatus()
        }
        .onDisappear {
            stopListeningApplyStatus()
        }
    }
    
    private func currentUserId() -> String? {
        return UserSessionManager.shared.currentUser?.id
    }
    
    private func startListeningApplyStatus() {
        // 기존 리스너 정리
        listener?.remove()
        listener = nil
        
        guard let uid = currentUserId() else { return }
        
        // participants.uid 필드가 존재하는 매치 문서를 리스닝 (participants는 map 형태라고 가정)
        let fieldPath = "participants.\(uid)"
        listener = db.collection("matches")
            .whereField(fieldPath, isGreaterThan: "")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("[NotiView] Firestore listen error: \(error)")
                    return
                }
                guard let snapshot = snapshot else { return }
                
                for change in snapshot.documentChanges {
                    let docId = change.document.documentID
                    let data = change.document.data()
                    // participants[uid] 의 상태 문자열을 가져옴
                    if let participants = data["participants"] as? [String: String],
                       let statusRaw = participants[uid] {
                        let message: String
                        let lowered = statusRaw.lowercased()
                        if lowered.contains("accepted") {
                            message = "매칭이 수락 되었습니다!"
                        } else if lowered.contains("rejected") {
                            message = "매칭이 거절 되었습니다."
                        } else if lowered.contains("pending") || lowered.contains("standby") || lowered.contains("applied") {
                            message = "매칭에 성공적으로 신청 되었습니다."
                        } else {
                            // 인지하지 못한 상태는 스킵
                            continue
                        }
                        
                        // 중복 방지: 동일 문서/상태 조합은 한 번만 처리
                        let uniqueKey = "\(docId)#\(lowered)"
                        if processedKeys.contains(uniqueKey) {
                            continue
                        }
                        processedKeys.insert(uniqueKey)
                        persistProcessedKeys()

                        // 리스트에 추가 및 저장 + 매핑 저장
                        notifications.insert(message, at: 0)
                        messageToDocId[message] = docId
                        persistNotifications()
                        persistMessageDocMap()

                        // 비동기로 매치 타이틀을 조회해 프리픽스 적용
                        fetchMatchTitle(matchId: docId) { fetchedTitle in
                            guard let fetchedTitle = fetchedTitle, !fetchedTitle.isEmpty else { return }
                            let prefixed = "[\(fetchedTitle)] \(message)"

                            // notifications(문자열)도 동기화: 첫 번째 항목을 업데이트(동일 타이밍 가정)
                            if let strIdx = notifications.firstIndex(of: message) {
                                notifications[strIdx] = prefixed
                            }
                            // 매핑 키도 갱신(표시 문자열 변경 시)
                            messageToDocId.removeValue(forKey: message)
                            messageToDocId[prefixed] = docId

                            persistNotifications()
                            persistMessageDocMap()
                        }
                    }
                }
            }
    }
    
    private func stopListeningApplyStatus() {
        listener?.remove()
        listener = nil
    }

    private func fetchMatchTitle(matchId: String, completion: @escaping (String?) -> Void) {
        db.collection("matches").document(matchId).getDocument { snapshot, error in
            if let error = error {
                print("[NotiView] Failed to fetch match title: \(error)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else { completion(nil); return }
            let title = data["title"] as? String
            completion(title)
        }
    }
    
    // MARK: - Persistence
    private func notificationsKey() -> String {
        let uid = currentUserId() ?? "anonymous"
        return "notifications_\(uid)"
    }

    private func loadStoredNotifications() {
        let key = notificationsKey()
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            notifications = saved
        }
    }

    private func persistNotifications() {
        let key = notificationsKey()
        UserDefaults.standard.set(notifications, forKey: key)
    }
    
    // MARK: - Processed Keys Persistence
    private func processedKeysKey() -> String {
        let uid = currentUserId() ?? "anonymous"
        return "processed_match_notifications_\(uid)"
    }

    private func loadProcessedKeys() {
        let key = processedKeysKey()
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            processedKeys = Set(saved)
        }
    }

    private func persistProcessedKeys() {
        let key = processedKeysKey()
        UserDefaults.standard.set(Array(processedKeys), forKey: key)
    }

    private func clearProcessedKeys() {
        processedKeys.removeAll()
        let key = processedKeysKey()
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Message -> DocID Map Persistence
    private func messageDocMapKey() -> String {
        let uid = currentUserId() ?? "anonymous"
        return "notification_message_doc_map_\(uid)"
    }

    private func loadMessageDocMap() {
        let key = messageDocMapKey()
        if let dict = UserDefaults.standard.dictionary(forKey: key) as? [String: String] {
            messageToDocId = dict
        }
    }

    private func persistMessageDocMap() {
        let key = messageDocMapKey()
        UserDefaults.standard.set(messageToDocId, forKey: key)
    }
}

private struct NotiPreviewWrapper: View {
    @State private var sample: [String] = [
        "[매칭 진행] 홍길동 님의 매칭이 진행 중입니다.",
        "[매칭 완료] 김영희 님과의 매칭이 성공적으로 완료되었습니다!",
        "[매칭 거절] 박철수 님이 매칭을 거절했습니다 ㅠㅠ."
    ]

    var body: some View {
        NotiView(notifications: $sample)
    }
}

#Preview {
    NavigationStack {
        NotiPreviewWrapper()
    }
}
