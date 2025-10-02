//
//  ApplyView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

// 지역 enum 정의
enum Region: String, CaseIterable {
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
    case professional = "상급"
    case elite = "중급"
    case amateur = "초급"
    case beginner = "입문자"
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
    
    // 달력 선택된 날짜
    @State private var selectedDate: Date = Date()
    
    // 필터 관련 상태
    @State private var currentFilter = GameFilter() // 현재 적용된 필터(적용하기를 눌렀을때만 업데이트됨)
    
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
                    .padding(.top, 8)  // 최소한의 상단 여백
                    .padding(.bottom, 12)
                    
                    // 스크랩, 필터, 지역 버튼 (통일된 스타일)
                    HStack(spacing: 12) {
                        // 스크랩 버튼
                        NavigationLink(destination: ScrapView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text("찜한 매치")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                        }
                        
                        // 필터 버튼
                        Button(action: {
                            isFilterSheetPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: currentFilter.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text("필터")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                        }
                        
                        // 지역 선택 버튼 (새로운 스타일)
                        Button(action: {
                            isRegionSheetPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "location")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text(selectedRegion.rawValue)
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
                    .padding(.bottom, 16)
                    
                    // 주간 달력 추가
                    CalendarView(selectedDate: $selectedDate)
                        .frame(height: 200)
                        .clipped()
                        .padding(.horizontal, 16)
                        .padding(.bottom, -100)
                    
                    // 게시글 공고 스크롤뷰
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // 스크롤 감지를 위한 투명한 뷰
                            Rectangle()
                                .fill(Color.clear
                                )
                                .frame(height: 1)
                                .id("top")
                                .onAppear {
                                    isScrolling = false
                                }
                                .onDisappear {
                                    isScrolling = true
                                }
                            
                            ApplyMatchListView(filter: currentFilter)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 0)
                        .padding(.bottom, 100) // 플로팅 버튼을 위한 여백
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
                .padding(.bottom, 34) // Safe Area 고려
            }
            //.navigationTitle("용병 모집")
        }
        .sheet(isPresented: $isRegionSheetPresented) {
            RegionBottomSheet(
                selectedRegion: $selectedRegion,
                isPresented: $isRegionSheetPresented
            )
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterBottomSheet(
                currentFilter: $currentFilter,
                isPresented: $isFilterSheetPresented
            )
        }
    }
    
    // 플로팅 액션 버튼
    private var floatingActionButton: some View {
        NavigationLink(destination: WritePostView()) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                
                if !isScrolling {
                    Text("글쓰기")
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

//// 샘플 게시글 카드 뷰
//struct PostCardView: View {
//    let title: String
//    let content: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.primary)
//            
//            Text(content)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .lineLimit(3)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
//    }
//}

#Preview {
    NavigationStack {
        ApplyView()
    }
}
