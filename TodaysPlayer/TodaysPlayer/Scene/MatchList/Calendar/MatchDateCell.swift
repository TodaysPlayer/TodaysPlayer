//
//  MatchDateCell.swift
//  TodaysPlayer
//
//  Created on 12/16/25.
//

import SwiftUI

// MARK: - MatchDateCell (경기 달력 날짜 셀)

struct MatchDateCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isPast: Bool
    let isCurrentMonth: Bool
    let hasMatches: Bool
    let matchCount: Int
    
    private var dayNumber: String {
        DateFormatter.dayNumber.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(textColor)
                .frame(height: 36)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .clipShape(Circle())
                .opacity(opacity)
            
            // 경기 개수 인디케이터
            if hasMatches && isCurrentMonth {
                Text("\(matchCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isSelected ? .primaryBaseGreen : isPast ? .gray : .orange)
                    .frame(width: 16, height: 16)
                    .background(isSelected ? .white : isPast ? .gray.opacity(0.2) : .orange.opacity(0.2))
                    .clipShape(Circle())
                    .opacity(isPast ? 0.5 : 1.0)
            } else {
                Color.clear
                    .frame(width: 16, height: 16)
            }
        }
        .frame(height: 60)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .clear
        } else if isPast {
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
        if !isCurrentMonth || isPast {
            return .clear
        } else if isSelected {
            return .primaryBaseGreen
        } else if isToday {
            return .primaryBaseGreen.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var opacity: Double {
        if !isCurrentMonth {
            return 0
        } else if isPast {
            return 0.3
        } else {
            return 1.0
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MatchDateCell(
            date: Date(),
            isSelected: false,
            isToday: true,
            isPast: false,
            isCurrentMonth: true,
            hasMatches: true,
            matchCount: 3
        )
        
        MatchDateCell(
            date: Date(),
            isSelected: true,
            isToday: false,
            isPast: false,
            isCurrentMonth: true,
            hasMatches: true,
            matchCount: 5
        )
        
        MatchDateCell(
            date: Date(),
            isSelected: false,
            isToday: false,
            isPast: true,
            isCurrentMonth: true,
            hasMatches: false,
            matchCount: 0
        )
    }
    .padding()
}
