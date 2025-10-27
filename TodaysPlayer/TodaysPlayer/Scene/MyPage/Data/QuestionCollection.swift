import Foundation

struct QuestionMessage: Codable, Identifiable {
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

final class QuestionCollection {
    static let shared = QuestionCollection()
    private let storageKey = "question_collection_storage_key"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func add(_ message: QuestionMessage) {
        var current = fetchAll()
        current.append(message)
        saveAll(current)
    }

    func fetchAll() -> [QuestionMessage] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        do {
            return try decoder.decode([QuestionMessage].self, from: data)
        } catch {
            return []
        }
    }

    private func saveAll(_ messages: [QuestionMessage]) {
        do {
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Silently ignore encoding errors for now
        }
    }

    func dumpAll() {
        let messages = fetchAll()
        if messages.isEmpty {
            print("[QuestionCollection] No messages saved.")
        } else {
            print("[QuestionCollection] Total: \(messages.count)")
            messages.forEach { print($0.debugDescription) }
        }
    }
}

extension QuestionMessage {
    var debugDescription: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return """
        [\(df.string(from: createdAt))] \(subject)
        - inquiryType: \(inquiryType)
        - contactEmail: \(contactEmail)
        - id: \(id.uuidString)
        - body: \(body)
        """
    }
}
