//
//  QuestionView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import Foundation

struct QuestionView: View {
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        
        VStack {
            Text("관리자에게 문의하기")
                .font(.largeTitle)
                .padding()
        }
    }
}
