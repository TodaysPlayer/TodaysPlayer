//
//  PwEditView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/1/25.
//

import SwiftUI

struct PwEditView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter your password")) {
                    
                }
            }
        }
        .background(Color.gray.opacity(0.1))
    }
}
