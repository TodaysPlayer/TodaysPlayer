//
//  MatchTag.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import Foundation
import SwiftUI

struct MatchTag: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let icon: String?
    
    init(text: String, color: Color, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }
}
