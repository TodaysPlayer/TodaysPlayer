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
                    HStack {
                        Text("\(participantData.userNickname)")
                            .font(.headline)
                     
                        Spacer()
 
                        HStack {
                            Image(systemName: "star.fill")
                            Text(String(format: "%.1f", viewModel.avgRating(for: participantData)))
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Text(participantData.position ?? "포지션무관")
                             .font(.caption)
                             .padding(.horizontal, 8)
                             .padding(.vertical, 4)
                             .background(Color.gray.opacity(0.3))
                             .clipShape(RoundedRectangle(cornerRadius: 8))
                             .visible(participantData.position != "")
                         
                         Text(participantData.userSkillLevel ?? "초급")
                             .font(.caption)
                             .padding(.horizontal, 8)
                             .padding(.vertical, 4)
                             .background(Color.gray.opacity(0.2))
                             .clipShape(RoundedRectangle(cornerRadius: 8))
                             .visible(participantData.userSkillLevel != "")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(participantData.appliedAt.relativeTimeString()) 신청")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.leading, 50)
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ApplyStatusConverter.toStatus(from: participantData.status) == .rejected ? "거절사유" : "신청내용")
                    .foregroundStyle(Color.gray.opacity(0.5))
                
                Text((ApplyStatusConverter.toStatus(from: participantData.status) == .rejected
                      ? participantData.rejectionReason ?? "내용없음"
                      : participantData.message) ?? "내용없음")
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
