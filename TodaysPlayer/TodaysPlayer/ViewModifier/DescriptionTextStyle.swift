//
//  DescriptionTextStyle.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

/// Text 설명글 스타일
struct DescriptionTextStyle: ViewModifier {
    var opacityValue: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(opacityValue))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
