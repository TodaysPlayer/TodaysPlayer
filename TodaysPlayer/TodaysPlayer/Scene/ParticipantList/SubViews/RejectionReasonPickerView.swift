//
//  SelectRejectionView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

// 픽커에서 Textfield로 처리할 수 있도록 화면은 빼고 눌렀을 때 textField 가 생기고 키보드가 올라와야함
struct RejectionReasonPickerView: View {
    private let options: [String] = RejectCase.allCases.map { $0.title }
    let participantData: ParticipantEntity
    
    @State private var selectedOption: String? = nil
    
    //    var onRejectButtonAction: ((RejectCase) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(ParticipantListViewModel.self) private var viewModel
    
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
                    guard let select = selectedOption,
                          let rejectCase = RejectCase(rawValue: select) else { return }
                    
                    dismiss()
                    
                    //                    onRejectButtonAction?(rejectCase)
                    viewModel.rejectButtonTapped(rejectCase, participantData)
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
