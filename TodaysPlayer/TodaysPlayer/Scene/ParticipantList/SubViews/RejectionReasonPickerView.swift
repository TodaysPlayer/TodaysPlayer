//
//  SelectRejectionView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct RejectionReasonPickerView: View {
    let options: [String] = [
        "이 경기의 목표와 맞지 않습니다",
        "팀원 조건과 맞지 않습니다(실력, 성별 등)",
        "소개글이 짧아서 어떤 분인지 알 수 없습니다",
        "기타(직접 작성)"
    ]
    
    @State private var selectedOption: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("거절 사유")
                        .font(.title3)
                    
                    Text("해당 내용은 신청자에게 전송됩니다")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                Button("거절하기") {
                    print("거절하기")
                }
                .foregroundStyle(Color.green)
            }
            
            VStack(spacing: 30) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selectedOption = option
                    } label: {
                        HStack {
                            Image(systemName: selectedOption == option ? "circle.fill" : "circle")
                                .foregroundStyle(selectedOption == option ? .green : .gray)
                            
                            Text(option)
                                .foregroundStyle(Color.black)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RejectionReasonPickerView()
}
