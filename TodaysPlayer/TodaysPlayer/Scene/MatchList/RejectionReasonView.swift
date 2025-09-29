//
//  RejectionReasonView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI

struct RejectionReasonView: View {
    @Environment(\.dismiss) private var dismiss
    let matchId: Int
    let rejectionReasion: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("경기 주최자의 거절사유입니다.")
                .padding(.top, 20)
            
            Text("경기 내용")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedCorner())
            
            Spacer()
            
            Button("확인") {
               dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.black)
            .background(Color.green)
            .clipShape(RoundedCorner())
        }
        .padding()
        .navigationTitle("거절사유")
    }
}


#Preview {
    RejectionReasonView(matchId: 0, rejectionReasion: "거절사유")
}
