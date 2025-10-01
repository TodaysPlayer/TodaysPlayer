//
//  ParticipantListView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantListView: View {
    @State private var viewModel = ParticipantListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    ParticipantSegmentControlView { status in
                        viewModel.fetchParticipantDatas(status: status)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.participantDatas, id: \.self) { participant in
                                ParticipantView(participantData: participant)
                                    .environment(viewModel)
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
            }
            .navigationTitle("인원 관리하기")
            .navigationDestination(isPresented: $viewModel.isShowWriteReasonView) {
                if let info = viewModel.rejectedPerson {
                    WriteRejectionReasonView(appliedPersonData: info)
                }
            }
            // 여기에서 바텀을 띄워야함
        }
    }
}
