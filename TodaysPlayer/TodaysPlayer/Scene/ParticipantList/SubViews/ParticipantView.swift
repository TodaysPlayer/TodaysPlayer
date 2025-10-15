//
//  ParticipantView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantView: View {
    let participantData: Apply
    let viewModel: ParticipantListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.gray)
                    

                VStack(alignment: .leading, spacing: 8) {
                    Text("(\(participantData.userNickname))")
                        .font(.headline)

                    HStack(spacing: 6) {
                        Text(participantData.position ?? "무관")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(participantData.userSkillLevel ?? "초급")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Text("\(participantData.appliedAt) 신청")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            
            VStack(alignment: .leading, spacing: 4) {
                Text("거절사유")
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .visible(ApplyStatusConverter.toStatus(from: participantData.status) == .rejected)
                
                Text(participantData.rejectionReason ?? "없음")
            }
            .modifier(DescriptionTextStyle())
            .padding(.top, 20)
            .visible(ApplyStatusConverter.toStatus(from: participantData.status) != .accepted)
            
            
            // 대기중의 경우 버튼 활성화
            Divider()
                .visible(ApplyStatusConverter.toStatus(from: participantData.status) == .standby)
            
            HStack(spacing: 10) {
                Button("거절") {
                    viewModel.isShowRejectSheet = true
                    viewModel.selectedPersonInfo = participantData
                }
                .foregroundStyle(Color.gray)
                .frame(maxWidth: .infinity, minHeight: 30)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1)
                
                Button("수락") {
                    viewModel.isShowAcceptAlert = true
                    viewModel.selectedPersonInfo = participantData
                }
                .foregroundStyle(Color.green)
                .frame(maxWidth: .infinity)
            }
            .visible(ApplyStatusConverter.toStatus(from: participantData.status) == .standby)
            
            
        }
        
    }
    
}
