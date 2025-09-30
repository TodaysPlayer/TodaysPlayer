//
//  MatchDashboardView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// MatchList DashBoard Component
struct MatchDashboardComponentView: View {
   var buttonTitle: String = ""
   var buttonCountTitle: Int = 0
   var buttonCountColor: Color = .black
    
    var body: some View {
        Button {
            print("대기중")
        } label: {
            VStack(alignment: .center, spacing: 10){
                Text("\(buttonCountTitle)")
                    .foregroundStyle(buttonCountColor)
                
                Text(buttonTitle)
                    .foregroundStyle(.black)
            }
            .frame(width: 100)
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


/// MatchList DashBoard
/// - 나의 매치 통계
struct MatchDashboardView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            MatchDashboardComponentView(
                buttonTitle: "확정 경기",
                buttonCountTitle: 0,
                buttonCountColor: .green
            )
            
            MatchDashboardComponentView(
                buttonTitle: "대기중",
                buttonCountTitle: 0,
                buttonCountColor: .red
            )
            MatchDashboardComponentView(
                buttonTitle: "마감/종료",
                buttonCountTitle: 0
            )
        }
    }
}

#Preview {
    MatchDashboardView()
}
