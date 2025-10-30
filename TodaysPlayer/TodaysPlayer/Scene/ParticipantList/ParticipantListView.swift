//
//  ParticipantListView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantListView: View {
    @State var viewModel: ParticipantListViewModel
    
    var body: some View {

        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
            VStack {
                CustomSegmentControlView(
                    categories: ApplyStatus.allCases
                        .filter({ $0 != .allType})
                        .map({ $0.rawValue}),
                    initialSelection: viewModel.selectedStatus.rawValue
                ) {
                    viewModel.fetchParticipantDatas(type: $0)
                }
                
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        Text("참여자가 없습니다.")
                            .visible(viewModel.displayedApplies.isEmpty)
                            .padding(.top, 50)

                        
                        ForEach(viewModel.displayedApplies) { participant in
                            ParticipantView(participantData: participant, viewModel: viewModel)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .refreshable {
                    await viewModel.fetchInitialDatas()
                }
            }
            
            ToastMessageView(manager: viewModel.toastManager)
            
        }
        .sheet(isPresented: $viewModel.isShowRejectSheet) {
            RejectionReasonPickerView(onRejectButtonTapped: { rejectCase, otherReason  in
                Task {
                   await viewModel.managementAppliedStatus(
                        status: .rejected,
                        rejectCase: rejectCase,
                        otherReason
                    )
                    
                    viewModel.toastManager.show(.participantRejected)
                }
            })
            .padding()
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: viewModel.isShowAcceptAlert) { _, newValue in
            if newValue {
                showSystemAlert(
                    title: "이 신청자를 수락할까요?",
                    message: "해당 신청자가 경기에 참여하게 됩니다.",
                    tint: .green,
                    actions: [
                        UIAlertAction(title: "취소", style: .cancel) { _ in
                            viewModel.isShowAcceptAlert = false
                        },
                        UIAlertAction(title: "수락", style: .destructive) { _ in
                            Task {
                                await viewModel.managementAppliedStatus(status: .accepted)
                                viewModel.toastManager.show(.participantAccepted)
                            }
                            viewModel.isShowAcceptAlert = false
                        }
                    ]
                )
            }
        }

        .navigationTitle("인원 관리하기")
    }
}
