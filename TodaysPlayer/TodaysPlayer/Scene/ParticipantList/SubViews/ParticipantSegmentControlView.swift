//
//  ParticipantSegmentConrolView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantSegmentControlView: View {
    let categories: [ApplyStatus] = ApplyStatus.allCases
    
    @State private var selectedStatus: ApplyStatus = .standby
    
    @Namespace private var namespace2
    
    var onSelectionChanged: ((ApplyStatus) -> Void)? = nil
    
    var body: some View {
        VStack {
            HStack {
                ForEach(categories, id: \.self) { status in
                    ZStack(alignment: .bottom) {
                        if selectedStatus == status {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.5))
                                .matchedGeometryEffect(id: "categoryBack", in: namespace2)
                                .frame(width: 50, height: 3)
                                .offset(y: 10)
                        }
                        
                        Text(status.rawValue)
                            .foregroundColor(selectedStatus == status ? .green : .gray)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedStatus = status
                            onSelectionChanged?(selectedStatus)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
