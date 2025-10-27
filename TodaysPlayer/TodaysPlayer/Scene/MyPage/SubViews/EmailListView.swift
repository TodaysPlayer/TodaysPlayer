import SwiftUI

struct StoredEmailMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let inquiryType: String
    let subject: String
    let body: String
    let contactEmail: String
    let createdAt: Date

    init(id: UUID = UUID(), inquiryType: String, subject: String, body: String, contactEmail: String, createdAt: Date = Date()) {
        self.id = id
        self.inquiryType = inquiryType
        self.subject = subject
        self.body = body
        self.contactEmail = contactEmail
        self.createdAt = createdAt
    }
}

final class EmailCollections {
    static let shared = EmailCollections()
    private let storageKey = "email_collection_storage_key"

    private init() {}

    func fetchAll() -> [StoredEmailMessage] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let msgs = try? decoder.decode([StoredEmailMessage].self, from: data) {
            return msgs
        }
        return []
    }

    func saveAll(_ msgs: [StoredEmailMessage]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(msgs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

struct EmailListView: View {
    @State private var messages: [StoredEmailMessage] = []
    @State private var selected: StoredEmailMessage?
    @State private var isPresentingDetail: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if messages.isEmpty {
                    ContentUnavailableView("No Emails", systemImage: "tray", description: Text("저장된 이메일이 없습니다."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(messages) { message in
                            Button {
                                selected = message
                                isPresentingDetail = true
                            } label: {
                                EmailRow(message: message)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("문의 사항")
            .onAppear(perform: reload)
            .refreshable { reload() }
            .sheet(isPresented: $isPresentingDetail) {
                if let selected {
                    EmailDetailView(message: selected)
                }
            }
        }
    }

    private func reload() {
        messages = EmailCollections.shared.fetchAll()
    }

    private func delete(at offsets: IndexSet) {
        var current = messages
        current.remove(atOffsets: offsets)
        EmailCollections.shared.saveAll(current)
        messages = current
    }
}

private struct EmailRow: View {
    let message: StoredEmailMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(message.subject)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(dateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Label(message.inquiryType, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(message.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }

    private var dateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: message.createdAt)
    }
}

private struct EmailDetailView: View {
    let message: StoredEmailMessage

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        Text("문의 제목").font(.caption).foregroundStyle(.secondary)
                        Text(message.subject).font(.title3)
                    }
                    Divider()
                    Group {
                        Text("문의 유형").font(.caption).foregroundStyle(.secondary)
                        Text(message.inquiryType)
                    }
                    Divider()
                    Group {
                        Text("연락받을 이메일").font(.caption).foregroundStyle(.secondary)
                        Text(UserSessionManager.shared.currentUser?.email ?? "")
                    }
                    Divider()
                    Group {
                        Text("문의 날짜").font(.caption).foregroundStyle(.secondary)
                        Text(dateString)
                    }
                    Divider()
                    Group {
                        Text("문의 내용").font(.caption).foregroundStyle(.secondary)
                        Text(message.body)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("문의 사항")
        }
    }

    private var dateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: message.createdAt)
    }
}

#Preview {
    // Provide some sample data for preview without touching UserDefaults
    let samples: [StoredEmailMessage] = [
        StoredEmailMessage(inquiryType: "Support", subject: "로그인 문제", body: "로그인이 되지 않습니다.", contactEmail: "user1@example.com"),
        StoredEmailMessage(inquiryType: "Feedback", subject: "앱이 좋아요", body: "디자인이 마음에 듭니다.", contactEmail: "user2@example.com"),
        StoredEmailMessage(inquiryType: "Bug", subject: "크래시 발생", body: "특정 화면에서 크래시가 발생합니다.", contactEmail: "user3@example.com")
    ]

    return NavigationStack {
        EmailListView()
            .onAppear {
                // Inject sample data for preview by saving to UserDefaults
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                if let data = try? encoder.encode(samples) {
                    UserDefaults.standard.set(data, forKey: "email_collection_storage_key")
                }
            }
    }
}
