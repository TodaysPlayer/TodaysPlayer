//
//  ParticipantView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantView: View {
    let participantData: ParticipantEntity
    @State private var isShowAcceptAlert: Bool = false
    @State private var isShowRejectSheet: Bool = false
    @Environment(ParticipantListViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10){
                HStack {
                    Image(systemName: "star.fill")
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundStyle(Color.green)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(participantData.userName)(\(participantData.userNickName))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text(participantData.userPosition)
                                .padding(.all, 5)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(participantData.userLevel)
                                .padding(.all, 5)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        
                        Text(participantData.appliedDate + " 신청")
                    }
                }
                
                if participantData.status != .accepted {
                    VStack(alignment: .leading, spacing: 4) {
                        if participantData.status == .rejected {
                            Text("거절사유")
                                .foregroundStyle(Color.gray.opacity(0.5))
                        }
                        
                        Text(participantData.description)
                    }
                    .modifier(DescriptionTextStyle())
                    .padding(.top, 20)
                }
                
                // 대기중의 경우 버튼 활성화
                if participantData.status == .standby {
                    Divider()
                    
                    HStack(spacing: 10) {
                        Button("거절") {
                            isShowRejectSheet = true
                            print("거절탭")
                        }
                        .foregroundStyle(Color.gray)
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 1)
                        
                        Button("수락") {
                            isShowAcceptAlert = true
                            print("수락탭")
                        }
                        .foregroundStyle(Color.green)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            // 이거 다 메인 view로 옮기기
            .sheet(isPresented: $isShowRejectSheet) {
                RejectionReasonPickerView(participantData: participantData)
                .padding()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
            .alert("이 신청자를 수락할까요?", isPresented: $isShowAcceptAlert) {
                Button("취소") {
                    isShowAcceptAlert = false
                }
                
                Button("수락") {
                    viewModel.managementAppliedStatus(participantData, .accepted)
                    isShowAcceptAlert = false
                }
                .foregroundStyle(Color.green)
            }
        }

    }
    
}
