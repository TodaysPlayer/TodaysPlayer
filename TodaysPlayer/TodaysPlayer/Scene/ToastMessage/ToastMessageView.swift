//
//  ToastMessage.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/2/25.
//

import SwiftUI

struct ToastMessageView: View {
    @State var manager: ToastMessageManager
    
    var body: some View {
        VStack {
            Spacer()
            
            if let message = manager.type?.message,
               manager.isShowing {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.primaryBaseGreen)
                    
                    Text(message)
                }
                .foregroundStyle(Color.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .clipShape(.buttonBorder)
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: manager.isShowing)
    }
}
