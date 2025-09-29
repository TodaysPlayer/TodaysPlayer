//
//  MyListSegmetControlView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI

struct MyListSegmentedControl: View {
    @State var preselectedIndex: Int
    
    var options: [String] = ["신청한 경기","모집중인 경기"]
    
    var body: some View {
        HStack {
            ForEach(options.indices, id:\.self) { index in
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(Color.green.opacity(0.8))
                        .cornerRadius(20)
                        .padding(2)
                        .opacity(preselectedIndex == index ? 1 : 0.01)
                        .onTapGesture {
                            withAnimation(.interactiveSpring()) {
                                preselectedIndex = index
                            }
                        }
                }
                .overlay(
                    Text(options[index])
                )
            }
        }
        .frame(height: 50)
        .cornerRadius(20)
    }
}
