import Foundation
import FirebaseFirestore
import FirebaseAuth

/**
 * FirestoreManager - Firebase DB 접근 공용모듈
 * 
 * 팀원들이 쉽게 사용할 수 있도록 컬렉션명, 도큐먼트명만 파라미터로 받아서
 * 원하는 데이터를 가져올 수 있는 간단한 메서드들을 제공합니다.
 * 
 * 사용법:
 * ```swift
 * let firestore = FirestoreManager.shared
 * let user: User? = try await firestore.getDocument(collection: "users", documentId: "user123", as: User.self)
 * let matches: [Match] = try await firestore.getDocuments(collection: "matches", as: Match.self)
 * ```
 */
class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - 기본 CRUD 작업
    
    /// 단일 문서 조회
    func getDocument<T: Codable>(collection: String, documentId: String, as type: T.Type) async throws -> T? {
        let document = try await db.collection(collection).document(documentId).getDocument()
        
        guard document.exists else {
            return nil
        }
        
        // 문서 ID를 userInfo에 전달하여 모델에서 사용할 수 있도록 함
        let decoder = Firestore.Decoder()
        decoder.userInfo[User.documentIdKey] = documentId
        decoder.userInfo[Match.documentIdKey] = documentId
        
        return try document.data(as: type, decoder: decoder)
    }
    
    /// 컬렉션의 모든 문서 조회
    func getDocuments<T: Codable>(collection: String, as type: T.Type) async throws -> [T] {
        let snapshot = try await db.collection(collection).getDocuments()
        return snapshot.documents.compactMap { document in
            let decoder = Firestore.Decoder()
            decoder.userInfo[User.documentIdKey] = document.documentID
            decoder.userInfo[Match.documentIdKey] = document.documentID
            return try? document.data(as: type, decoder: decoder)
        }
    }
    
    /// 조건부 쿼리 (단일 조건)
    func queryDocuments<T: Codable>(collection: String, where field: String, isEqualTo value: Any, as type: T.Type) async throws -> [T] {
        let snapshot = try await db.collection(collection).whereField(field, isEqualTo: value).getDocuments()
        return snapshot.documents.compactMap { document in
            let decoder = Firestore.Decoder()
            decoder.userInfo[User.documentIdKey] = document.documentID
            decoder.userInfo[Match.documentIdKey] = document.documentID
            return try? document.data(as: type, decoder: decoder)
        }
    }
    
    /// 문서 생성
    func createDocument<T: Codable>(collection: String, documentId: String? = nil, data: T) async throws -> String {
        print("🔥 FirestoreManager.createDocument 호출: collection=\(collection), documentId=\(documentId ?? "nil")")
        
        let docRef: DocumentReference
        
        if let documentId = documentId {
            docRef = db.collection(collection).document(documentId)
        } else {
            docRef = db.collection(collection).document()
        }
        
        do {
            try docRef.setData(from: data)
            print("✅ FirestoreManager.createDocument 성공: \(docRef.documentID)")
            return docRef.documentID
        } catch {
            print("❌ FirestoreManager.createDocument 실패: \(error)")
            print("❌ 에러 타입: \(type(of: error))")
            print("❌ 에러 상세: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 문서 업데이트
    func updateDocument(collection: String, documentId: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(documentId).updateData(data)
    }
    
    /// 문서 삭제
    func deleteDocument(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }
    
    // MARK: - 서브컬렉션 작업
    
    /// 서브컬렉션 문서 조회
    func getSubcollectionDocument<T: Codable>(collection: String, documentId: String, subcollection: String, subdocumentId: String, as type: T.Type) async throws -> T? {
        let document = try await db.collection(collection).document(documentId).collection(subcollection).document(subdocumentId).getDocument()
        
        guard document.exists else {
            return nil
        }
        
        return try document.data(as: type)
    }
    
    /// 서브컬렉션의 모든 문서 조회
    func getSubcollectionDocuments<T: Codable>(collection: String, documentId: String, subcollection: String, as type: T.Type) async throws -> [T] {
        let snapshot = try await db.collection(collection).document(documentId).collection(subcollection).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: type) }
    }
    
    /// 서브컬렉션 문서 생성
    func createSubcollectionDocument<T: Codable>(collection: String, documentId: String, subcollection: String, subdocumentId: String? = nil, data: T) async throws -> String {
        print("🔥 FirestoreManager.createSubcollectionDocument 호출: collection=\(collection), documentId=\(documentId), subcollection=\(subcollection), subdocumentId=\(subdocumentId ?? "nil")")
        
        let docRef: DocumentReference
        
        if let subdocumentId = subdocumentId {
            docRef = db.collection(collection).document(documentId).collection(subcollection).document(subdocumentId)
        } else {
            docRef = db.collection(collection).document(documentId).collection(subcollection).document()
        }
        
        do {
            try docRef.setData(from: data)
            print("✅ FirestoreManager.createSubcollectionDocument 성공: \(docRef.documentID)")
            return docRef.documentID
        } catch {
            print("❌ FirestoreManager.createSubcollectionDocument 실패: \(error)")
            print("❌ 에러 타입: \(type(of: error))")
            print("❌ 에러 상세: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - 실시간 리스너
    
    /// 컬렉션 실시간 리스너
    func addListener<T: Codable>(collection: String, as type: T.Type, completion: @escaping ([T]) -> Void) -> Any {
        return db.collection(collection).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            let documents = snapshot?.documents.compactMap { try? $0.data(as: type) } ?? []
            completion(documents)
        }
    }
    
    /// 서브컬렉션 실시간 리스너
    func addSubcollectionListener<T: Codable>(collection: String, documentId: String, subcollection: String, as type: T.Type, completion: @escaping ([T]) -> Void) -> Any {
        return db.collection(collection).document(documentId).collection(subcollection).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            let documents = snapshot?.documents.compactMap { try? $0.data(as: type) } ?? []
            completion(documents)
        }
    }
    
    /// 서브컬렉션 삭제
    func deleteSubcollection(collection: String, documentId: String, subcollection: String) async throws {
        let subcollectionRef = db.collection(collection).document(documentId).collection(subcollection)
        let snapshot = try await subcollectionRef.getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// 컬렉션의 모든 문서 ID 가져오기
    func getDocumentIds(collection: String) async throws -> [String] {
        let snapshot = try await db.collection(collection).getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
}