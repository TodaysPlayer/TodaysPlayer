//
//  MonthCalendarView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/13/25.
//

import SwiftUI

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(spacing: 16) {
            // 월/년도 헤더
            monthYearHeader
            
            // 요일 헤더
            weekDayHeader
            
            // 날짜 그리드
            monthDateGrid
        }
        .padding()
    }
    
    // MARK: - 월/년도 헤더
    private var monthYearHeader: some View {
        HStack {
            Button(action: moveToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.green)
                    .padding(8)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: moveToNextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.green)
                    .padding(8)
            }
        }
    }
    
    // MARK: - 요일 헤더
    private var weekDayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - 날짜 그리드
    private var monthDateGrid: some View {
        let daysInMonth = generateDaysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    MonthDateCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        isPast: isPastDate(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                    )
                    .onTapGesture {
                        if !isPastDate(date) {
                            selectedDate = date
                        }
                    }
                } else {
                    // 빈 셀
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// 월/년도 문자열
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentMonth)
    }
    
    /// 해당 월의 날짜 배열 생성 (앞뒤 빈 칸 포함)
    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        // 최대 6주 표시 (42일)
        for _ in 0..<42 {
            if calendar.isDate(date, equalTo: monthInterval.start, toGranularity: .month) {
                days.append(date)
            } else if date < monthInterval.start {
                days.append(nil) // 이전 달 빈칸
            } else if days.count < 35 { // 최소 5주는 보여주기
                days.append(nil) // 다음 달 빈칸
            } else {
                break
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return days
    }
    
    /// 과거 날짜인지 확인
    private func isPastDate(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let compareDate = calendar.startOfDay(for: date)
        return compareDate < today
    }
    
    // MARK: - Actions
    
    /// 이전 달로 이동
    private func moveToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    /// 다음 달로 이동
    private func moveToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
}

// MARK: - MonthDateCell (월간 달력 날짜 셀)

struct MonthDateCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isPast: Bool
    let isCurrentMonth: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Text(dayNumber)
            .font(.system(size: 16, weight: isSelected ? .bold : .regular))
            .foregroundColor(textColor)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(Circle())
            .opacity(opacity)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .clear // 다른 달 날짜는 숨김
        } else if isPast {
            return .gray
        } else if isSelected {
            return .white
        } else if isToday {
            return .green
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if !isCurrentMonth || isPast {
            return .clear
        } else if isSelected {
            return .green
        } else if isToday {
            return .green.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var opacity: Double {
        if !isCurrentMonth {
            return 0 // 다른 달 날짜는 완전히 숨김
        } else if isPast {
            return 0.3
        } else {
            return 1.0
        }
    }
}

// MARK: - Preview

#Preview {
    MonthCalendarView(selectedDate: .constant(Date()))
}
