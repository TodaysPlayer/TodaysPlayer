//
//  ConfirmButton.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import SwiftUI

struct ConfirmButton: View {
    let onConfirm: () -> Void
    
    var body: some View {
        Button(action: onConfirm) {
            Text("선택하기")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.futsalGreen)
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}
