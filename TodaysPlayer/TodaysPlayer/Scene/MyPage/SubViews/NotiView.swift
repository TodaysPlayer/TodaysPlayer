//
//  NotiView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI

struct NotiView: View {
    // 주입 가능한 알림 데이터. 바인딩으로 받아 삭제가 반영됩니다.
    @Binding var notifications: [String]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("알림")
                    .font(.title2).bold()
                Spacer()
                Button(action: { notifications.removeAll() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .padding(8)
                }
                .accessibilityLabel("모든 알림 삭제")
                .disabled(notifications.isEmpty)
                .tint(.red)
            }
            .padding(.horizontal)

            // 내용
            if notifications.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("매칭진행 / 완료 등등 \n알람이 이곳에 표시됩니다!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(notifications, id: \.self) { message in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                            Text(message)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
        // 시트(아래에서 올라오는 모달) 표현 설정
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NotiView(notifications: .constant([]))
}
