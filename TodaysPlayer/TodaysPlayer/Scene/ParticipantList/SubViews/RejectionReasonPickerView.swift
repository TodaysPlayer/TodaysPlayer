//
//  SelectRejectionView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct RejectionReasonPickerView: View {
    private let options: [String] = RejectCase.allCases.map { $0.title }
    @State private var selectedOption: String = ""
    @State private var rejectionReason: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var onRejectButtonTapped: ((RejectCase, String?) -> Void)? = nil
    
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
                    guard let rejectCase = RejectCase(rawValue: selectedOption) else { return }
                    
                    dismiss()
                    
                    onRejectButtonTapped?(rejectCase, rejectionReason)
                }
                .foregroundStyle(Color.green)
            }
            
            VStack(spacing: 30) {
                ForEach(options, id: \.self) { option in
                    VStack(alignment: .leading, spacing: 10) {
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
                    
                        TextField("거절하는 이유를 적어주세요.", text: $rejectionReason)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading, 30)
                            .visible(selectedOption == RejectCase.etc.title &&
                                     option == RejectCase.etc.title)
                    }
                }
            }
        }
    }
}
