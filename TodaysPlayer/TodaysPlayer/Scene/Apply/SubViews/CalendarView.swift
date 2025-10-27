//
//  CalendarView.swift
//  TodaysPlayer
//
//  Created by J on 9/29/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentWeekStart: Date = Date().startOfWeek
    
    private let calendar = Calendar.current
    private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
    
    private var todayWeekStart: Date {
        Date().startOfWeek
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 월/년도 헤더
            monthYearHeader
            
            // 요일 헤더
            weekDayHeader
            
            // 날짜 그리드
            weekDateGrid
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .gesture(
            DragGesture()
                .onEnded { value in
                    handleSwipe(value: value)
                }
        )
    }
    
    // MARK: - 월/년도 헤더
    private var monthYearHeader: some View {
        HStack {
            Button(action: moveToPreviousWeek) {
                Image(systemName: "chevron.left")
                    .foregroundColor(canMoveToPreviousWeek ? .primaryBaseGreen : .secondary)
                    .padding(8)
            }
            .disabled(!canMoveToPreviousWeek)
            
            Spacer()
            
            Text(monthYearString)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: moveToNextWeek) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primaryBaseGreen)
                    .padding(8)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - 요일 헤더
    private var weekDayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - 날짜 그리드
    private var weekDateGrid: some View {
        HStack(spacing: 0) {
            ForEach(weekDates.enumerated(), id: \.offset) { index, date in
                DateCell(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isToday: calendar.isDateInToday(date),
                    isPast: isPastDate(date)
                )
                .onTapGesture {
                    // 과거 날짜는 선택 불가
                    if !isPastDate(date) {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties
    
    /// 현재 주의 날짜 배열 (일요일~토요일)
    private var weekDates: [Date] {
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: currentWeekStart) {
                dates.append(date)
            }
        }
        return dates
    }
    
    /// 월/년도 문자열 (예: "10월 2025")
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentWeekStart)
    }
    
    // 과거 날짜인지 확인
    private func isPastDate(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let compareDate = calendar.startOfDay(for: date)
        return compareDate < today
    }
    
    private var canMoveToPreviousWeek: Bool {
        return currentWeekStart > todayWeekStart
    }
    
    // MARK: - Actions
    
    /// 이전 주로 이동
    private func moveToPreviousWeek() {
        // 오늘이 속한 주보다 이전으로는 못 가게 제한
        guard let newWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart),
              newWeekStart >= todayWeekStart else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeekStart = newWeekStart
            selectedDate = newWeekStart
        }
    }
    
    /// 다음 주로 이동
    private func moveToNextWeek() {
        if let newWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentWeekStart = newWeekStart
                selectedDate = newWeekStart
            }
        }
    }
    
    /// 스와이프 제스처 처리
    private func handleSwipe(value: DragGesture.Value) {
        let threshold: CGFloat = 50
        
        if value.translation.width > threshold {
            // 오른쪽 스와이프 → 이전 주
            moveToPreviousWeek()
        } else if value.translation.width < -threshold {
            // 왼쪽 스와이프 → 다음 주
            moveToNextWeek()
        }
    }
}

// MARK: - DateCell (날짜 셀)

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isPast: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(textColor)
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .clipShape(Circle())
                .opacity(isPast ? 0.3 : 1.0) // 과거 날짜는 반투명
            
            // 오늘 날짜 인디케이터
            if isToday && !isSelected {
                Circle()
                    .fill(Color.primaryBaseGreen)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var textColor: Color {
        // 과거 날짜는 회색으로
        if isPast {
            return .gray
        } else if isSelected {
            return .white
        } else if isToday {
            return .primaryBaseGreen
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        // 과거 날짜는 선택되어도 배경색 없음
        if isPast {
            return .clear
        } else if isSelected {
            return .primaryBaseGreen
        } else {
            return .clear
        }
    }
}

// MARK: - Date Extension (주의 시작일 계산)

extension Date {
    /// 해당 날짜가 속한 주의 일요일 날짜 반환
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CalendarView(selectedDate: .constant(Date()))
            .frame(height: 200)
            .padding()
        
        Spacer()
    }
}
