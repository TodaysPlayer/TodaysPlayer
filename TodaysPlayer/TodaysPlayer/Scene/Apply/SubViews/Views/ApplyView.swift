//
//  ApplyView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct ApplyView: View {
    @State private var isRegionSheetPresented: Bool = false
    @State private var isFilterSheetPresented: Bool = false
    @State private var isScrolling: Bool = false
    @State private var filterButtonScale: CGFloat = 1.0
    
    @StateObject private var filterViewModel = FilterViewModel()
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // 타이틀
                    VStack(alignment: .leading, spacing: 4) {
                        Text("용병 모집")
                            .font(.title.bold())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    
                    // 필터 버튼
                    HStack(spacing: 12) {
                        Button(action: {
                            isFilterSheetPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: filterViewModel.currentFilter.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(filterViewModel.currentFilter.isEmpty ? .blue : .white)
                                Text("필터")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(filterViewModel.currentFilter.isEmpty ? .primary : .white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                filterViewModel.currentFilter.isEmpty
                                    ? Color(.systemBackground)
                                    : Color.blue.opacity(0.85)
                            )
                            .cornerRadius(16)
                            .scaleEffect(filterButtonScale)
                        }
                        
                        Button(action: {
                            isRegionSheetPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "location")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text(filterViewModel.currentFilter.region.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    // 주간 달력
                    CalendarView(selectedDate: $filterViewModel.selectedDate)
                        .frame(height: 150)
                        .clipped()
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .onChange(of: filterViewModel.selectedDate) { oldValue, newValue in
                            filterViewModel.applyFilter()
                        }
                    
                    // 매치 리스트
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 1)
                                .id("top")
                                .onAppear {
                                    isScrolling = false
                                }
                                .onDisappear {
                                    isScrolling = true
                                }
                            
                            FirebaseMatchListView()
                                .environmentObject(filterViewModel)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 0)
                        .padding(.bottom, 100)
                    }
                }
                
                // 플로팅 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButton
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 34)
            }
        }
        .sheet(isPresented: $isRegionSheetPresented) {
            RegionBottomSheet(
                filterViewModel: filterViewModel,
                isPresented: $isRegionSheetPresented
            )
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterBottomSheet(
                isPresented: $isFilterSheetPresented
            )
            .environmentObject(filterViewModel)
            .onDisappear {
                triggerBounceAnimation()
            }
        }
        .onAppear {
            filterViewModel.fetchInitialMatches()
        }
    }

    private func triggerBounceAnimation() {
        guard !filterViewModel.currentFilter.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            filterButtonScale = 1.15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                filterButtonScale = 1.0
            }
        }
    }
    
    private var floatingActionButton: some View {
        NavigationLink(destination: WritePostView()
            .environmentObject(filterViewModel)
        ) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill.badge.plus")
                    .font(.system(size: 18, weight: .semibold))
                
                if !isScrolling {
                    Text("모집하기")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, isScrolling ? 16 : 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: isScrolling ? 28 : 25)
                    .fill(Color.green)
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isScrolling)
    }
}
