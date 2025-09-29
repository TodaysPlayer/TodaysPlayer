import Foundation
import FirebaseAuth

/**
 * SampleDataManager - Firebase DB에 샘플 데이터를 생성하는 매니저
 * 
 * 개발/테스트용으로 각 컬렉션에 샘플 데이터를 자동으로 생성합니다.
 * HomeView에서 버튼을 눌러 실행할 수 있습니다.
 */
class SampleDataManager {
    static let shared = SampleDataManager()
    private let firestore = FirestoreManager.shared
    
    private init() {}
    
    /// 모든 샘플 데이터 생성
    func createAllSampleData() async throws {
        print("🔥 샘플 데이터 생성 시작...")
        print("🔥 FirestoreManager.shared: \(FirestoreManager.shared)")
        
        // Firebase 인증 상태 확인 (개발용으로 임시 비활성화)
        print("🔥 Firebase 인증 상태 확인 중...")
        print("⚠️ 개발용: 인증 없이 진행합니다. Firebase Console에서 보안 규칙을 수정해주세요.")
        print("⚠️ Firestore 보안 규칙을 다음으로 설정하세요:")
        print("⚠️ allow read, write: if true;")
        
        // 개발용으로 인증 없이 진행
        // 실제 배포 시에는 인증을 활성화해야 합니다
        
        // 기존 데이터 확인 및 삭제
        print("🔥 기존 데이터 확인 중...")
        try await clearExistingData()
        
        do {
            print("🔥 사용자 데이터 생성 시작...")
            try await createSampleUsers()
            print("✅ 사용자 데이터 생성 완료")
            
            print("🔥 매치 데이터 생성 시작...")
            try await createSampleMatches()
            print("✅ 매치 데이터 생성 완료")
            
            print("🔥 지역 데이터 생성 시작...")
            try await createSampleRegions()
            print("✅ 지역 데이터 생성 완료")
            
            print("🔥 공지사항 데이터 생성 시작...")
            try await createSampleAnnouncements()
            print("✅ 공지사항 데이터 생성 완료")
            
            print("🔥 신청 데이터 생성 시작...")
            try await createSampleApplications()
            print("✅ 신청 데이터 생성 완료")
            
            print("🔥 알림 데이터 생성 시작...")
            try await createSampleNotifications()
            print("✅ 알림 데이터 생성 완료")
            
            print("🎉 모든 샘플 데이터 생성 완료!")
        } catch {
            print("❌ 샘플 데이터 생성 실패: \(error)")
            print("❌ 에러 타입: \(type(of: error))")
            print("❌ 에러 상세: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - 기존 데이터 삭제
    
    private func clearExistingData() async throws {
        print("🔥 기존 데이터 삭제 중...")
        
        // 각 컬렉션의 모든 문서 삭제
        let collections = ["users", "matches", "regions", "announcements", "apply"]
        
        for collection in collections {
            do {
                // Firebase에서 직접 문서 ID 가져오기 (더 안전함)
                let documentIds = try await firestore.getDocumentIds(collection: collection)
                
                print("🔥 \(collection) 컬렉션에서 \(documentIds.count)개 문서 삭제 중...")
                
                for documentId in documentIds {
                    try await firestore.deleteDocument(collection: collection, documentId: documentId)
                }
                print("✅ \(collection) 컬렉션 삭제 완료")
            } catch {
                print("⚠️ \(collection) 컬렉션 삭제 실패 (이미 비어있을 수 있음): \(error)")
            }
        }
        
        // 사용자 서브컬렉션도 삭제 (알림)
        do {
            let users = try await firestore.getDocuments(collection: "users", as: User.self)
            for user in users {
                try await firestore.deleteSubcollection(collection: "users", documentId: user.id, subcollection: "notifications")
            }
            print("✅ 사용자 알림 서브컬렉션 삭제 완료")
        } catch {
            print("⚠️ 사용자 알림 서브컬렉션 삭제 실패 (이미 비어있을 수 있음): \(error)")
        }
        
        print("✅ 기존 데이터 삭제 완료")
    }
    
    // MARK: - 사용자 데이터
    
    private func createSampleUsers() async throws {
        let users = [
            User(
                id: "bJYjlQZuaqvw2FDB5uNa", // 고정된 사용자 ID (스태틱)
                email: "player1@example.com",
                displayName: "축구왕김철수",
                profileImageUrl: nil,
                phoneNumber: "010-1234-5678",
                position: "striker",
                skillLevel: "intermediate",
                preferredRegions: ["서울특별시", "경기도"],
                isTeamLeader: true,
                teamId: nil,
                createdAt: Date(),
                updatedAt: Date(),
                isActive: true
            ),
            User(
                id: "", // 자동 생성
                email: "player2@example.com",
                displayName: "미드필더박영희",
                profileImageUrl: nil,
                phoneNumber: "010-2345-6789",
                position: "midfielder",
                skillLevel: "advanced",
                preferredRegions: ["경기도", "인천광역시"],
                isTeamLeader: false,
                teamId: nil,
                createdAt: Date(),
                updatedAt: Date(),
                isActive: true
            ),
            User(
                id: "", // 자동 생성
                email: "player3@example.com",
                displayName: "골키퍼이민수",
                profileImageUrl: nil,
                phoneNumber: "010-3456-7890",
                position: "goalkeeper",
                skillLevel: "beginner",
                preferredRegions: ["인천광역시"],
                isTeamLeader: false,
                teamId: nil,
                createdAt: Date(),
                updatedAt: Date(),
                isActive: true
            )
        ]
        
        for user in users {
            let documentId = try await firestore.createDocument(collection: "users", data: user)
            print("✅ 사용자 생성됨: \(documentId)")
        }
        
        print("✅ 사용자 데이터 생성 완료")
    }
    
    // MARK: - 매치 데이터
    
    private func createSampleMatches() async throws {
        // 먼저 사용자들을 가져와서 첫 번째 사용자를 주최자로 사용
        let users = try await firestore.getDocuments(collection: "users", as: User.self)
        guard let firstUser = users.first else {
            print("⚠️ 사용자가 없어서 매치 생성 건너뜀")
            return
        }
        
        print("🔥 매치 생성에 사용할 사용자: \(firstUser.displayName) (ID: \(firstUser.id))")
        
        // 매치별 참가자 정보 (사용자 ID와 상태)
        let participants1 = [
            "bJYjlQZuaqvw2FDB5uNa": "accepted" // 주최자만
        ]
        
        let participants2 = [
            "bJYjlQZuaqvw2FDB5uNa": "accepted", // 주최자
            "user2": "pending" // 대기중
        ]
        
        let participants3 = [
            "bJYjlQZuaqvw2FDB5uNa": "accepted", // 주최자
            "user3": "accepted" // 수락됨
        ]
        
        let matches = [
            Match(
                id: "", // 자동 생성
                title: "주말 축구 매치 - 강남구",
                description: "주말에 즐기는 축구 매치입니다. 실력 무관 누구나 참여 가능!",
                organizerId: firstUser.id,
                teamId: nil,
                matchType: "individual",
                location: MatchLocation(
                    name: "강남풋살파크",
                    address: "서울특별시 강남구 테헤란로 123",
                    coordinates: Coordinates(latitude: 37.5665, longitude: 126.9780)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                duration: 90,
                maxParticipants: 10,
                skillLevel: "intermediate",
                position: "striker",
                price: 0,
                status: "recruiting",
                tags: ["주말", "친선", "실력무관"],
                requirements: "축구화 착용 필수",
                participants: participants1,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Match(
                id: "", // 자동 생성
                title: "실력별 축구 대회 - 분당구",
                description: "실력별로 나누어 진행하는 축구 대회입니다.",
                organizerId: firstUser.id,
                teamId: nil,
                matchType: "individual",
                location: MatchLocation(
                    name: "분당축구센터",
                    address: "경기도 성남시 분당구 판교역로 456",
                    coordinates: Coordinates(latitude: 37.3947, longitude: 127.1112)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                duration: 120,
                maxParticipants: 16,
                skillLevel: "advanced",
                position: "midfielder",
                price: 5000,
                status: "recruiting",
                tags: ["대회", "실력별", "상금"],
                requirements: "중급 이상 실력자만 참여 가능",
                participants: participants2,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Match(
                id: "", // 자동 생성
                title: "초보자 축구 교실 - 인천",
                description: "축구를 처음 배우는 분들을 위한 교실입니다.",
                organizerId: firstUser.id,
                teamId: nil,
                matchType: "individual",
                location: MatchLocation(
                    name: "인천축구아카데미",
                    address: "인천광역시 연수구 컨벤시아대로 789",
                    coordinates: Coordinates(latitude: 37.4138, longitude: 126.6788)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                duration: 60,
                maxParticipants: 20,
                skillLevel: "beginner",
                position: nil,
                price: 0,
                status: "recruiting",
                tags: ["교실", "초보자", "교육"],
                requirements: "축구화 없이도 참여 가능",
                participants: participants3,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Match(
                id: "", // 자동 생성
                title: "야간 축구 매치 - 송파구",
                description: "야간에 진행하는 축구 매치입니다. 직장인들 환영!",
                organizerId: firstUser.id,
                teamId: nil,
                matchType: "individual",
                location: MatchLocation(
                    name: "송파축구장",
                    address: "서울특별시 송파구 올림픽로 300",
                    coordinates: Coordinates(latitude: 37.5154, longitude: 127.1218)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                duration: 90,
                maxParticipants: 12,
                skillLevel: "intermediate",
                position: "defender",
                price: 3000,
                status: "recruiting",
                tags: ["야간", "직장인", "친선"],
                requirements: "야간 조명 시설 완비",
                participants: participants1,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Match(
                id: "", // 자동 생성
                title: "고수들만의 매치 - 부천시",
                description: "고수들만 참여하는 고강도 매치입니다.",
                organizerId: firstUser.id,
                teamId: nil,
                matchType: "individual",
                location: MatchLocation(
                    name: "부천축구센터",
                    address: "경기도 부천시 원미구 길주로 210",
                    coordinates: Coordinates(latitude: 37.5044, longitude: 126.7650)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                duration: 120,
                maxParticipants: 14,
                skillLevel: "advanced",
                position: "goalkeeper",
                price: 8000,
                status: "recruiting",
                tags: ["고수", "고강도", "경쟁"],
                requirements: "고급 실력자만 참여 가능",
                participants: participants2,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        for match in matches {
            let documentId = try await firestore.createDocument(collection: "matches", data: match)
            print("✅ 매치 생성됨: \(documentId)")
        }
        
        print("✅ 매치 데이터 생성 완료")
    }
    
    // MARK: - 지역 데이터
    
    private func createSampleRegions() async throws {
        let regions = [
            RegionData(
                id: "", // 자동 생성
                name: "서울특별시",
                parentRegion: nil,
                coordinates: Coordinates(latitude: 37.5665, longitude: 126.9780)
            ),
            RegionData(
                id: "", // 자동 생성
                name: "경기도",
                parentRegion: nil,
                coordinates: Coordinates(latitude: 37.4138, longitude: 127.5183)
            ),
            RegionData(
                id: "", // 자동 생성
                name: "인천광역시",
                parentRegion: nil,
                coordinates: Coordinates(latitude: 37.4563, longitude: 126.7052)
            ),
            RegionData(
                id: "", // 자동 생성
                name: "강남구",
                parentRegion: "서울특별시",
                coordinates: Coordinates(latitude: 37.5172, longitude: 127.0473)
            ),
            RegionData(
                id: "", // 자동 생성
                name: "분당구",
                parentRegion: "경기도",
                coordinates: Coordinates(latitude: 37.3947, longitude: 127.1112)
            )
        ]
        
        for region in regions {
            let documentId = try await firestore.createDocument(collection: "regions", data: region)
            print("✅ 지역 생성됨: \(documentId)")
        }
        
        print("✅ 지역 데이터 생성 완료")
    }
    
    // MARK: - 공지사항 데이터
    
    private func createSampleAnnouncements() async throws {
        let announcements = [
            Announcement(
                id: "", // 자동 생성
                title: "새로운 매치 시스템 업데이트",
                content: "더 나은 매치 매칭을 위한 새로운 시스템이 업데이트되었습니다.",
                isImportant: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Announcement(
                id: "", // 자동 생성
                title: "주말 특별 이벤트 안내",
                content: "이번 주말 특별 이벤트가 진행됩니다. 많은 참여 부탁드립니다.",
                isImportant: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        for announcement in announcements {
            let documentId = try await firestore.createDocument(collection: "announcements", data: announcement)
            print("✅ 공지사항 생성됨: \(documentId)")
        }
        
        print("✅ 공지사항 데이터 생성 완료")
    }
    
    // MARK: - 신청 데이터
    
    private func createSampleApplications() async throws {
        // 먼저 사용자들과 매치들을 가져와서 실제 ID 사용
        let users = try await firestore.getDocuments(collection: "users", as: User.self)
        let matches = try await firestore.getDocuments(collection: "matches", as: Match.self)
        
        guard users.count >= 2, matches.count >= 2 else {
            print("⚠️ 사용자나 매치가 부족해서 신청 생성 건너뜀 (사용자: \(users.count)개, 매치: \(matches.count)개)")
            return
        }
        
        print("🔥 신청 생성에 사용할 사용자: \(users.count)명, 매치: \(matches.count)개")
        
        let applications = [
            Apply(
                id: "", // 자동 생성
                matchId: matches[0].id,
                applicantId: users[1].id,
                position: "midfielder",
                participantCount: 1,
                message: "열심히 참여하겠습니다!",
                status: "pending",
                rejectionReason: nil,
                appliedAt: Date(),
                processedAt: nil
            ),
            Apply(
                id: "", // 자동 생성
                matchId: matches[1].id,
                applicantId: users[2].id,
                position: "goalkeeper",
                participantCount: 1,
                message: "고수들과 함께 뛰고 싶습니다.",
                status: "accepted",
                rejectionReason: nil,
                appliedAt: Date(),
                processedAt: Date()
            )
        ]
        
        for application in applications {
            let documentId = try await firestore.createDocument(collection: "apply", data: application)
            print("✅ 신청 생성됨: \(documentId)")
        }
        
        print("✅ 신청 데이터 생성 완료")
    }
    
    // MARK: - 알림 데이터
    
    private func createSampleNotifications() async throws {
        // 먼저 사용자와 매치들을 가져와서 실제 ID 사용
        let users = try await firestore.getDocuments(collection: "users", as: User.self)
        let matches = try await firestore.getDocuments(collection: "matches", as: Match.self)
        
        guard let firstUser = users.first, let firstMatch = matches.first else {
            print("⚠️ 사용자나 매치가 없어서 알림 생성 건너뜀 (사용자: \(users.count)개, 매치: \(matches.count)개)")
            return
        }
        
        print("🔥 알림 생성에 사용할 사용자: \(firstUser.displayName) (ID: \(firstUser.id))")
        
        let notifications = [
            Notification(
                id: "", // 자동 생성
                type: "application_received",
                title: "새로운 신청이 도착했습니다",
                message: "축구왕김철수님이 매치에 신청했습니다.",
                data: ["matchId": firstMatch.id],
                isRead: false,
                createdAt: Date()
            ),
            Notification(
                id: "", // 자동 생성
                type: "application_accepted",
                title: "신청이 승인되었습니다",
                message: "실력별 축구 대회 신청이 승인되었습니다.",
                data: ["matchId": firstMatch.id],
                isRead: true,
                createdAt: Date()
            )
        ]
        
        // 알림은 users/{userId}/notifications 서브컬렉션에 저장
        for notification in notifications {
            let documentId = try await firestore.createSubcollectionDocument(
                collection: "users",
                documentId: firstUser.id,
                subcollection: "notifications",
                data: notification
            )
            print("✅ 알림 생성됨: \(documentId) (사용자 ID: \(firstUser.id))")
        }
        
        print("✅ 알림 데이터 생성 완료")
    }
}
