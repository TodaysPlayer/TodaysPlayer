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
            // Removed the header HStack with title and delete button

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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(.title2)
                    .bold()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { notifications.removeAll() }) {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("모든 알림 삭제")
                .disabled(notifications.isEmpty)
                .tint(.red)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // 시트(아래에서 올라오는 모달) 표현 설정
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
//        .navigationBarBackButtonHidden()
    }
}

private struct NotiPreviewWrapper: View {
    @State private var sample: [String] = [
        "[매칭 진행] 홍길동 님의 매칭이 진행 중입니다.",
        "[매칭 완료] 김영희 님과의 매칭이 성공적으로 완료되었습니다!",
        "[매칭 거절] 박철수 님이 매칭을 거절했습니다 ㅠㅠ."
    ]

    var body: some View {
        NotiView(notifications: $sample)
    }
}

#Preview {
    NavigationStack {
        NotiPreviewWrapper()
    }
}
