//
//  WritePostViewModel.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/2/25.
//

import Foundation
import Observation

@Observable
final class WritePostViewModel {
    // MARK: - Form Fields
    var title: String = ""
    var description: String = ""
    var matchType: String = "futsal" // "futsal", "soccer"
    var gender: String = "mixed" // "male", "female", "mixed"
    var selectedDate: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    var duration: Int = 120 // 기본 120분
    var maxParticipants: Int = 6
    var skillLevel: String = "beginner" // "beginner", "intermediate", "advanced", "expert"
    var hasFee: Bool = false
    var price: Int = 0
    var selectedLocation: MatchLocation?
    
    // MARK: - UI State
    var isLoading: Bool = false
    var showLocationSearch: Bool = false
    var errorMessage: String?
    
    // MARK: - Validation
    var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        selectedLocation != nil &&
        maxParticipants > 0
    }
    
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        let dateString = formatter.string(from: selectedDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let startTimeString = timeFormatter.string(from: startTime)
        let endTimeString = timeFormatter.string(from: endTime)
        
        return "\(dateString) \(startTimeString)~\(endTimeString)"
    }
    
    // MARK: - Actions
    func createMatch(organizerId: String) async throws -> Match {
        guard isFormValid else {
            throw ValidationError.invalidForm
        }
        
        guard let location = selectedLocation else {
            throw ValidationError.noLocation
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // 시간 계산 (duration)
        let durationInMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        
        // Match 객체 생성
        let match = Match(
            id: UUID().uuidString,
            title: title,
            description: description,
            organizerId: organizerId,
            organizerName: "test1",
            organizerProfileURL: "",
            teamId: nil,
            matchType: matchType,
            gender: gender,
            location: location,
            dateTime: combineDateAndTime(date: selectedDate, time: startTime),
            duration: durationInMinutes > 0 ? durationInMinutes : 120,
            maxParticipants: maxParticipants,
            skillLevel: skillLevel,
            position: nil,
            price: hasFee ? price : 0,
            rating: nil,
            status: "recruiting",
            tags: [],
            requirements: nil,
            participants: [:],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Firebase에 저장
        _ = try await FirestoreManager.shared.createDocument(
            collection: "matches",
            documentId: match.id,
            data: match
        )
        
        return match
    }
    
    // 날짜와 시간을 합치는 헬퍼 함수
    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        
        return calendar.date(from: mergedComponents) ?? date
    }
    
    func reset() {
        title = ""
        description = ""
        matchType = "futsal"
        gender = "mixed"
        selectedDate = Date()
        startTime = Date()
        endTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        duration = 120
        maxParticipants = 6
        skillLevel = "beginner"
        hasFee = false
        price = 0
        selectedLocation = nil
        errorMessage = nil
    }
}

// MARK: - Validation Errors
enum ValidationError: LocalizedError {
    case invalidForm
    case noLocation
    case invalidTime
    
    var errorDescription: String? {
        switch self {
        case .invalidForm:
            return "모든 필수 항목을 입력해주세요"
        case .noLocation:
            return "장소를 선택해주세요"
        case .invalidTime:
            return "시간을 올바르게 입력해주세요"
        }
    }
}
