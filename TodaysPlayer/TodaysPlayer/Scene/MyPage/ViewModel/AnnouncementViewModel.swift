import SwiftUI
import FirebaseFirestore

// Model representing an announcement fetched from Firestore
struct AnnouncementSv: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let content: String
    let createdAt: Date
}

// Model used in the UI
struct AnnouncementSvList: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

@Observable
final class AnnouncementViewModel {
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    var announcements: [AnnouncementList] = []
    var state: LoadingState = .idle

    func fetch() async {
        if case .loading = state { return }
        state = .loading
        do {
            // Firestore에서 Announcement 모델 배열을 가져온다
            let items: [Announcement] = try await FirestoreManager.shared.getDocuments(collection: "announcements", as: Announcement.self)

            // 정렬: 최신 생성 순 (createdAt 내림차순)
            let sorted = items.sorted { $0.createdAt > $1.createdAt }

            // UI에서 사용하는 AnnouncementList로 매핑
            self.announcements = sorted.map { AnnouncementList(title: $0.title, content: $0.content) }
            self.state = .loaded
        } catch {
            self.state = .failed(error.localizedDescription)
        }
    }
}
