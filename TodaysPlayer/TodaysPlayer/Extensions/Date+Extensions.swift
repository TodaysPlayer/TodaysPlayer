//
//  Date+Extensions.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import Foundation

extension Date {
    /// 날짜/시간을 사용자 친화적 형식으로 포맷팅
    /// - Returns: "오늘 14:30", "내일 09:00", "12/25일 15:00분" 등
    func formatForDisplay() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            formatter.dateFormat = "HH시mm분"
            return "오늘 \(formatter.string(from: self))"
        } else if calendar.isDateInTomorrow(self) {
            formatter.dateFormat = "HH시mm분"
            return "내일 \(formatter.string(from: self))"
        } else {
            formatter.dateFormat = "MM월dd일  HH시mm분"
            return formatter.string(from: self)
        }
    }
    
    /// 간단한 시간 포맷팅 (HH:mm)
    func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시mm분"
        return formatter.string(from: self)
    }
    
    /// 간단한 날짜 포맷팅 (MM/dd)
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월dd일"
        return formatter.string(from: self)
    }
    
    /// 상대적 시간 표시 (몇 시간 전, 몇 일 전 등)
    func relativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatTimeRange(duration: Int) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        let endTime = self.addingTimeInterval(TimeInterval(duration * 60))
        
        if calendar.isDateInToday(self) {
            formatter.dateFormat = "HH시mm분"
            return "오늘 \(formatter.string(from: self))~\(formatter.string(from: endTime))"
        } else if calendar.isDateInTomorrow(self) {
            formatter.dateFormat = "HH시mm분"
            return "내일 \(formatter.string(from: self))~\(formatter.string(from: endTime))"
        } else {
            formatter.dateFormat = "MM월dd일 HH시mm분"
            let startStr = formatter.string(from: self)
            formatter.dateFormat = "HH시mm분"
            return "\(startStr)~\(formatter.string(from: endTime))"
        }
    }
}
