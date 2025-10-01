//
//  SettingView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import Foundation

struct SettingView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: PwEditView()) {
                Text("비밀번호 변경")
            }
            Text("회원 탈퇴")
                .foregroundStyle(Color(.red))
        }
//        .background(Color.gray.opacity(0.1))
    }
}
