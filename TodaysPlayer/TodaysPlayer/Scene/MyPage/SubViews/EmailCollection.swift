import Foundation

struct EmailMessage: Codable, Identifiable {
    let id: UUID
    let inquiryType: String
    let subject: String
    let body: String
    let contactEmail: String
    let createdAt: Date

    init(inquiryType: String, subject: String, body: String, contactEmail: String) {
        self.id = UUID()
        self.inquiryType = inquiryType
        self.subject = subject
        self.body = body
        self.contactEmail = contactEmail
        self.createdAt = Date()
    }
}

final class EmailCollection {
    static let shared = EmailCollection()
    private init() {}

    private let storageKey = "email_collection_storage_key"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func add(_ message: EmailMessage) {
        var current = fetchAll()
        current.append(message)
        saveAll(current)
    }

    func fetchAll() -> [EmailMessage] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        do {
            return try decoder.decode([EmailMessage].self, from: data)
        } catch {
            return []
        }
    }

    private func saveAll(_ messages: [EmailMessage]) {
        do {
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Silently ignore encoding errors for now
        }
    }
}
