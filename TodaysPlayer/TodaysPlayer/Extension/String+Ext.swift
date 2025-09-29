//
//  String+Ext.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI

extension String {
    
    /// String 특정 부분 색상변경
    /// - Parameters:
    ///   - part: 변경할 부분
    ///   - color: 변경할 색상
    func highlighted(part: String, color: Color) -> AttributedString {
        var attr = AttributedString(self)
        if let range = attr.range(of: part) {
            attr[range].foregroundColor = color
            attr[range].font = .headline
        }
        return attr
    }
}
