//
//  CalendarView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/29/25.
//

import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.scope = .week   // 주간 달력 모드
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.locale = Locale(identifier: "ko_KR") // 한국어
        
        // 달력 높이 제한
//        calendar.headerHeight = 40  // 헤더 높이 줄이기
//        calendar.weekdayHeight = 30  // 요일 높이 줄이기
//        calendar.appearance.headerMinimumDissolvedAlpha = 0.0  // 헤더 단순화
//        
//        calendar.contentView.layoutMargins = .zero
//        
//        if let collectionView = calendar.collectionView {
//                collectionView.contentInset = .zero
//        }
//            
//        calendar.clipsToBounds = true
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 선택된 날짜가 바뀌면 UI 반영
        uiView.select(selectedDate)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date // 선택된 날짜 업데이트
        }
    }
}
