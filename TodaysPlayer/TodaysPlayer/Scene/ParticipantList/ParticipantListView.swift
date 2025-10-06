//
//  ParticipantListView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantListView: View {
    @State private var viewModel = ParticipantListViewModel()
    @State private var selectedStatus: ApplyStatus = .standby

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    ParticipantSegmentControlView(
                        categories: ApplyStatus.allCases.map({$0.rawValue}),
                        initialSelection: viewModel.selectedStatus.rawValue
                    ) { status in
                        viewModel.fetchParticipantDatas(status: ApplyStatus(rawValue: status.rawValue) ?? .standby)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.participantDatas, id: \.self) { participant in
                                ParticipantView(participantData: participant, viewModel: viewModel)
                                    .padding(10)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 1, y: 1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                
                ToastMessageView(manager: viewModel.toastManager)

            }
            .sheet(isPresented: $viewModel.isShowRejectSheet) {
                RejectionReasonPickerView(onRejectButtonTapped: { rejectCase, otherReason  in
                    viewModel.managementAppliedStatus(
                        status: .rejected,
                        rejectCase: rejectCase,
                        otherReason
                    )
                    
                    viewModel.toastManager.show(.participantRejected)
                })
                .padding()
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
            }
            .alert("이 신청자를 수락할까요?", isPresented: $viewModel.isShowAcceptAlert) {
                Button("취소") {}
                
                Button("수락") {
                    viewModel.managementAppliedStatus(status: .accepted)
                    viewModel.toastManager.show(.participantAccepted)
                }
                .foregroundStyle(Color.green)
            }
            .navigationTitle("인원 관리하기")
        }
    }
}

#Preview {
    ParticipantListView()
}
