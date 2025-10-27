//
//  MatchTagStyle.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

/// 경기정보 태그 스타일
struct MatchTagStyle: ViewModifier {
    var tag: TagStyle
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .foregroundColor(tag.textColor)
            .background(tag.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(tag.borderColor.opacity(0.2), lineWidth: 1)
            )
    }
}
