//
//  PersonalityView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI

struct PersonalityView: View {
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        Text("개인정보 처리 방침")
            .navigationBarTitle("개인정보 처리 방침")
            .navigationBarItems(trailing: Button("닫기") {
                self.presentationMode.wrappedValue.dismiss()
            })
    }
}
