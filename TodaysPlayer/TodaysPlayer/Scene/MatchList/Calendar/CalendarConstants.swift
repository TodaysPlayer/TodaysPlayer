//
//  CalendarConstants.swift
//  TodaysPlayer
//
//  Created on 12/16/25.
//

import Foundation

// MARK: - Calendar Constants

enum CalendarConstants {
    /// 요일 헤더 (일 ~ 토)
    static let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
    
    /// 한국 로케일
    static let koreanLocale = Locale(identifier: "ko_KR")
    
    /// 달력 행 수 (6주)
    static let maxWeeksInMonth = 6
    
    /// 달력 최대 일 수 (6주 * 7일)
    static let maxDaysInMonth = 42
    
    /// 요일별 색상 (일요일: 빨강, 토요일: 파랑)
    static func colorForWeekday(_ day: String) -> ColorType {
        switch day {
        case "일": return .sunday
        case "토": return .saturday
        default: return .weekday
        }
    }
    
    enum ColorType {
        case sunday, saturday, weekday
    }
}

// MARK: - DateFormatter Extensions

extension DateFormatter {
    /// 한국어 년월 포맷 (예: "2025년 12월")
    static let koreanYearMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = CalendarConstants.koreanLocale
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()
    
    /// 한국어 월일 요일 포맷 (예: "12월 16일 (월)")
    static let koreanMonthDayWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = CalendarConstants.koreanLocale
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()
    
    /// 숫자 일자 포맷 (예: "16")
    static let dayNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    /// 시간 포맷 (예: "14:30")
    static let hourMinute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = CalendarConstants.koreanLocale
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    /// 한국어 요일 약자 포맷 (예: "월")
    static let koreanWeekdayShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = CalendarConstants.koreanLocale
        formatter.dateFormat = "E"
        return formatter
    }()
    
    #if DEBUG
    /// 디버깅용 상세 날짜 포맷
    static let debugDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    #endif
}

// MARK: - Calendar Utilities

extension Calendar {
    /// 특정 날짜가 과거인지 확인 (오늘 기준)
    func isPastDate(_ date: Date) -> Bool {
        let today = startOfDay(for: Date())
        let compareDate = startOfDay(for: date)
        return compareDate < today
    }
    
    /// 특정 날짜가 오늘이 속한 달인지 확인
    func isInCurrentMonth(_ date: Date) -> Bool {
        let today = Date()
        return isDate(date, equalTo: today, toGranularity: .month)
    }
    
    /// 해당 월의 첫 날 가져오기
    func startOfMonth(for date: Date) -> Date? {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)
    }
    
    /// 해당 월의 날짜 배열 생성 (달력용, 빈 칸 포함)
    func generateMonthDates(for date: Date) -> [Date?] {
        guard let monthInterval = dateInterval(of: .month, for: date),
              let monthFirstWeek = dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        // 최대 6주 표시 (42일)
        for _ in 0..<CalendarConstants.maxDaysInMonth {
            if isDate(currentDate, equalTo: date, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil) // 다른 달의 날짜는 nil
            }
            
            currentDate = self.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    /// 이전 달로 이동 가능한지 확인
    func canMoveToPreviousMonth(from currentMonth: Date) -> Bool {
        guard let currentMonthStart = startOfMonth(for: currentMonth),
              let todayMonthStart = startOfMonth(for: Date()) else {
            return false
        }
        
        return startOfDay(for: currentMonthStart) > startOfDay(for: todayMonthStart)
    }
}
