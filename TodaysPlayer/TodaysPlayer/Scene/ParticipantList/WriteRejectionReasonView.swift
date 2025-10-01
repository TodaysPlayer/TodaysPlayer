//
//  WriteRejectionReasonView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/1/25.
//

import SwiftUI

struct WriteRejectionReasonView: View {
    @State private var viewModel: WriteRejectionReasonViewModel = WriteRejectionReasonViewModel()
    
    let appliedPersonData: ParticipantEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("해당 참가자를 거절하게 된 이유를 적어주세요")
                .bold()
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.textEditor)
                    .frame(height: 150)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .onChange(of: viewModel.textEditor, { _, newValue in
                        if newValue.count > viewModel.limit {
                            viewModel.textEditor = String(newValue.prefix(viewModel.limit))
                        }
                    })
            
                if viewModel.textEditor.count == 0 {
                    Text("ex) 욕설 등의 부적절한 말을 사용했습니다. 저희 경기와 맞지 않습니다")
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
            }
            
            HStack {
                Spacer()
                Text("\(viewModel.textEditor.count) / \(viewModel.limit)")
                    .foregroundStyle(Color.gray)
            }
            
            Spacer()
            
            Text("해당 내용은 신청자에게 전송됩니다")
                .foregroundStyle(Color.gray)
            
            Button("거절하기") {
                viewModel.rejectAppliedPerson(appliedPersonData)
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
            .foregroundStyle(Color.white)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))

        }
        .padding()
        .navigationTitle("거절하기")
    }
        
}

#Preview {
    WriteRejectionReasonView(
        appliedPersonData: ParticipantEntity(
            matchId: 0,
            userName: "용헌",
            userNickName: "용헌",
            userProfile: "",
            userLevel: "중",
            userPosition: "몰루",
            description: "신청합니다",
            appliedDate: "2025-10-1",
            status: .standby
        )
    )
}
