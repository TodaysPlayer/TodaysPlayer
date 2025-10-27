//
//  Color+Extensions.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/27/25.
//

import SwiftUI

extension Color {
    static let primaryBaseGreen = Color(hex: "#4CAF50")
    static let primaryDark = Color(hex: "#2E7D32")
    static let primaryLight = Color(hex: "#A5D6A7")
    static let futsalGreen = Color(hex: "#66BB6A")        
    
    static let secondaryCoolGray = Color(hex: "#E0E0E0")
    static let secondaryDeepGray = Color(hex: "#616161")
    static let secondaryMintGreen = Color(hex: "#80CBC4")
    
    static let accentOrange = Color(hex: "#FFB74D")
    static let accentRed = Color(hex: "#E53935")
}


extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}
