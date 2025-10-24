//
//  ApplyView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

// 지역 enum 정의
enum Region: String, CaseIterable {
    case all = "전체"
    case seoul = "서울"
    case gyeonggi = "경기"
    case incheon = "인천"
    case gangwon = "강원"
    case daejeonSejong = "대전/세종"
    case chungbuk = "충북"
    case chungnam = "충남"
    case daegu = "대구"
    case busan = "부산"
    case ulsan = "울산"
    case gyeongbuk = "경북"
    case gyeongnam = "경남"
    case gwangju = "광주"
    case jeonbuk = "전북"
    case jeonnam = "전남"
    case jeju = "제주"
}

// 실력 레벨 enum
enum SkillLevel: String, CaseIterable {
    case beginner = "초급"
    case intermediate = "중급"
    case advanced = "고급"
    case expert = "상급"
}

enum Gender: String, CaseIterable {
    case male = "남성"
    case female = "여성"
}

// 참가비 enum
enum FeeType: String, CaseIterable {
    case free = "무료"
    case paid = "유료"
}

// 필터 데이터 구조체
struct GameFilter {
    var matchType: MatchType? = nil // 단일 선택: 축구 or 풋살
    var skillLevels: Set<SkillLevel> = [] // 복수선택: 프로, 아마추어 둘 다 가능
    var gender: Gender? = nil // 단일 선택: 남자만 or 여자만
    var feeType: FeeType? = nil // 단일 선택: 무료 or 유료
    var region: Region = .all
    
    // 서버로 보낼 딕셔너리 형태로 변환
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let matchType = matchType {
            dict["matchType"] = matchType.rawValue
        }
        
        if !skillLevels.isEmpty {
            dict["levelLimits"] = skillLevels.map { $0.rawValue }  // String 배열로 변환
        }
        
        // 단일 선택 항목들은 단일 값으로 전송
        if let gender = gender {
            dict["genderLimit"] = gender.rawValue
        }
        
        if let feeType = feeType {
            dict["feeType"] = feeType.rawValue
        }
        
        return dict
    }
    
    // 필터가 비어있는지 확인
    var isEmpty: Bool {
        return matchType == nil && skillLevels.isEmpty && gender == nil && feeType == nil
    }
}

struct ApplyView: View {
    @State private var selectedRegion: Region = .incheon
    @State private var isRegionSheetPresented: Bool = false
    @State private var isFilterSheetPresented: Bool = false
    @State private var isScrolling: Bool = false
    
    @StateObject private var filterViewModel = FilterViewModel()
    
    // 필터 관련 상태
    @State private var currentFilter = GameFilter()
    
    // FavoriteViewModel 추가
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    // 바운스 애니메이션을 위한 상태 추가
    @State private var filterButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // 커스텀 타이틀 (네비게이션 타이틀 대신)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("용병 모집")
                            .font(.title.bold())
                        
                        Text("함께할 팀원을 찾아보세요")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    
                    // 스크랩, 필터, 지역 버튼 (통일된 스타일)
                    HStack(spacing: 12) {
                        // 스크랩 버튼 (아이콘 변경)
//                        NavigationLink(destination: ScrapView()) {
//                            HStack(spacing: 6) {
//                                // 삼항연산자로 아이콘 변경
//                                Image(systemName: favoriteViewModel.favoritedMatchIds.isEmpty ? "bookmark" : "bookmark.fill")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.blue)
//                                Text("찜한 매치")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.primary)
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .background(Color(.systemBackground))
//                            .cornerRadius(16)
//                        }
                        
                        // 필터 버튼 - 개선된 버전
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
                                // 필터 적용 시 파란색 배경
                                filterViewModel.currentFilter.isEmpty
                                    ? Color(.systemBackground)
                                    : Color.blue.opacity(0.85)
                            )
                            .cornerRadius(16)
                            .scaleEffect(filterButtonScale) // 바운스 효과
                        }
                        
                        // 지역 선택 버튼 (새로운 스타일)
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
                    
                    // 주간 달력 - filterViewModel.selectedDate 사용
                    CalendarView(selectedDate: $filterViewModel.selectedDate)
                        .frame(height: 150)
                        .clipped()
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .onChange(of: filterViewModel.selectedDate) { oldValue, newValue in
                            // 날짜 변경 시 필터 재적용
                            filterViewModel.applyFilter()
                        }
                    
                    // 게시글 공고 스크롤뷰
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // 스크롤 감지를 위한 투명한 뷰
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
                
                // 플로팅 액션 버튼
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
                // 필터 시트가 닫힐 때 바운스 애니메이션 트리거
                triggerBounceAnimation()
            }
        }
        .onAppear {
            // 초기 데이터 로드 (selectedDate는 filterViewModel이 관리)
            filterViewModel.fetchInitialMatches()
        }
    }
    
    // 바운스 애니메이션 함수
    private func triggerBounceAnimation() {
        // 필터가 비어있지 않을 때만 애니메이션 실행
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
    
    // 플로팅 액션 버튼
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

#Preview {
    NavigationStack {
        ApplyView()
            .environmentObject(FavoriteViewModel())
    }
}
