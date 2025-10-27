//
//  ProgressViewStyle.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/7/25.
//

import SwiftUI


/// 인원수 표시 ProgressView Style
struct LinearGaugeProgressStyle: ProgressViewStyle {
    var tintColor: Color = .primaryBaseGreen
    var backgroundColor: Color = .primaryBaseGreen.opacity(0.2)
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                
                Capsule()
                    .fill(tintColor)
                    .frame(width: fractionCompleted * geometry.size.width)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
