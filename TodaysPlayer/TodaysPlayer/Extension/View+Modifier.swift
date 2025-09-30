//
//  View+Modifier.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI

extension View {
    /// 경기정보 태그 스타일
    func matchTagStyle(tagType: TagStyle) -> some View {
        self.modifier(MatchTagStyle(tag: tagType))
    }
}
