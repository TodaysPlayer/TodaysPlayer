//
//  CalendarMatchView.swift
//  TodaysPlayer
//
//  Created on 12/09/25.
//

import SwiftUI

struct CalendarMatchView: View {
  @State private var viewModel = CalendarMatchViewModel()
  @State private var selectedDate: Date = Date()
  @State private var currentMonth: Date = Calendar.current.startOfDay(for: Date())

  private let calendar = Calendar.current
  private let weekDays = CalendarConstants.weekDays

  var body: some View {
      ZStack(alignment: .top) {
        // 메인 스크롤뷰 (달력 + 경기 목록 함께 스크롤)
        ScrollView {
          VStack(spacing: 0) {
            // 전체 달력 (스크롤과 함께 올라감)
            fullCalendarSection
              .padding(.horizontal)
              .padding(.vertical, 12)
              .background(Color(.systemBackground))

            // 경기 목록
            matchListContent
              .padding(.top, 8)
          }
        }
    }
    .background(Color(.systemGroupedBackground).ignoresSafeArea())
    .navigationDestination(for: Match.self) { match in
      MatchDetailView(match: match)
    }
    .task {
      // 초기 로드
      await loadMatchesForCurrentMonth()
    }
    .onChange(of: currentMonth) { _, newMonth in
      // 월 변경시 데이터 다시 로드
      Task {
        await loadMatchesForCurrentMonth()
      }
    }
    .onChange(of: viewModel.isFinishMatchAlertShow) { _, newValue in
      if newValue {
        showFinishMatchAlert()
      }
    }
  }

  // MARK: - Data Loading
  
  private func loadMatchesForCurrentMonth() async {
    await MainActor.run {
      viewModel.fetchMatchesForMonth(date: currentMonth)
    }
  }
  
  // MARK: - Calendar Sections

  // 전체 달력
  private var fullCalendarSection: some View {
    VStack(spacing: 12) {
      monthYearHeader
      weekDayHeader
      monthDateGrid
    }
  }

  private var monthYearHeader: some View {
    HStack {
      Button(action: moveToPreviousMonth) {
        Image(systemName: "chevron.left")
          .foregroundColor(canMoveToPreviousMonth ? .primaryBaseGreen : .gray)
          .padding(8)
      }
      .disabled(!canMoveToPreviousMonth)
      
      Spacer()
      
      Text(monthYearString)
        .font(.title3.bold())
        .foregroundColor(.primary)
      
      Spacer()
      
      Button(action: moveToNextMonth) {
        Image(systemName: "chevron.right")
          .foregroundColor(.primaryBaseGreen)
          .padding(8)
      }
    }
  }
  
  private var weekDayHeader: some View {
    HStack(spacing: 0) {
      ForEach(weekDays, id: \.self) { day in
        Text(day)
          .font(.caption.bold())
          .foregroundColor(day == "일" ? .red : day == "토" ? .blue : .secondary)
          .frame(maxWidth: .infinity)
      }
    }
  }
  
  private var monthDateGrid: some View {
    let daysInMonth = generateDaysInMonth()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    return LazyVGrid(columns: columns, spacing: 8) {
      ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
        if let date = date {
          MatchDateCell(
            date: date,
            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
            isToday: calendar.isDateInToday(date),
            isPast: isPastDate(date),
            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
            hasMatches: viewModel.hasMatches(on: date),
            matchCount: viewModel.getMatchCount(on: date)
          )
          .onTapGesture {
            // 과거 날짜도 경기가 있으면 선택 가능하도록 변경
            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
              selectedDate = date
            }
          }
        } else {
          // 빈 셀
          Color.clear
            .frame(height: 44)
        }
      }
    }
  }
  
  // MARK: - Match List Section
  
  private var matchListContent: some View {
    Group {
      let selectedDayStart = calendar.startOfDay(for: selectedDate)
      
      if viewModel.isLoading {
        // 로딩 상태
        loadingStateView
          .frame(height: 300)
      } else if let matches = viewModel.matchesByDate[selectedDayStart], !matches.isEmpty {
        // 경기가 있는 경우
        LazyVStack(spacing: 12) {
          // 선택된 날짜 헤더
          selectedDateHeader
            .padding(.horizontal)
            .padding(.top)
          
          ForEach(matches) { match in
            NavigationLink(value: match) {
              matchCardView(match: match)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
          }
          
          // 하단 여백
          Color.clear
            .frame(height: 20)
        }
      } else {
        // 경기가 없는 경우
        emptyStateView
          .frame(height: 300)
      }
    }
  }
  
  private var loadingStateView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)
      
      Text("경기 정보를 불러오는 중...")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .frame(maxHeight: .infinity)
    .padding()
  }
  
  private var selectedDateHeader: some View {
    HStack {
      Text(selectedDateString)
        .font(.headline)
        .foregroundColor(.primary)
      
      Spacer()
      
      if let matchCount = viewModel.matchesByDate[calendar.startOfDay(for: selectedDate)]?.count {
        Text("\(matchCount)개의 경기")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
    .padding(.bottom, 8)
  }
  
  private func matchCardView(match: Match) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      // 경기 제목 & 시간
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 8) {
            Text(match.title)
              .font(.headline)
              .foregroundColor(.primary)
            
            // 내가 모집중인 경기 배지
            if viewModel.isMyRecruitingMatch(match) {
              HStack(spacing: 4) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                  .font(.system(size: 10, weight: .semibold))
                Text("내 경기")
                  .font(.system(size: 11, weight: .semibold))
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(
                LinearGradient(
                  colors: [.primaryBaseGreen, .primaryBaseGreen.opacity(0.7)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .foregroundColor(.white)
              .cornerRadius(8)
            }
          }
          
          Text(timeString(from: match.dateTime))
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        
        Spacer()
      }
      
      // 경기 상태 태그들
      FlowLayout(spacing: 8) {
        ForEach(viewModel.getMatchTags(for: match), id: \.text) { tag in
          tagView(tag: tag)
        }
      }
      
      // 경기 정보
      HStack(spacing: 16) {
        Label(match.location.name, systemImage: "location.fill")
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
        
        Label("\(match.appliedParticipantsCount)/\(match.maxParticipants)", systemImage: "person.fill")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(
      viewModel.isMyRecruitingMatch(match)
      ? LinearGradient(
        colors: [Color.primaryBaseGreen.opacity(0.05), Color.white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      : LinearGradient(colors: [Color.white, Color.white], startPoint: .top, endPoint: .bottom)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(
          viewModel.isMyRecruitingMatch(match) ? Color.primaryBaseGreen.opacity(0.3) : Color.clear,
          lineWidth: 2
        )
    )
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
  }
  
  private func tagView(tag: MatchTag) -> some View {
    HStack(spacing: 4) {
      if let icon = tag.icon {
        Image(systemName: icon)
          .font(.system(size: 10))
      }
      Text(tag.text)
        .font(.system(size: 12, weight: .medium))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(tag.color.opacity(0.15))
    .foregroundColor(tag.color)
    .cornerRadius(12)
  }
  
  // MARK: - Empty State
  
  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "calendar.badge.exclamationmark")
        .font(.system(size: 48))
        .foregroundColor(.gray)
      
      Text("해당 날짜에 경기가 없습니다")
        .font(.headline)
        .foregroundColor(.gray)
      
      Text(selectedDateString)
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .frame(maxHeight: .infinity)
    .padding()
  }
  
  // MARK: - Helper Methods
  
  private var monthYearString: String {
    DateFormatter.koreanYearMonth.string(from: currentMonth)
  }
  
  private var selectedDateString: String {
    DateFormatter.koreanMonthDayWeekday.string(from: selectedDate)
  }
  
  private var canMoveToPreviousMonth: Bool {
    calendar.canMoveToPreviousMonth(from: currentMonth)
  }
  
  private func generateDaysInMonth() -> [Date?] {
    calendar.generateMonthDates(for: currentMonth)
  }
  
  private func isPastDate(_ date: Date) -> Bool {
    calendar.isPastDate(date)
  }
  
  private func moveToPreviousMonth() {
    if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
      currentMonth = newMonth
      // onChange가 자동으로 데이터를 로드합니다
    }
  }
  
  private func moveToNextMonth() {
    if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
      currentMonth = newMonth
      // onChange가 자동으로 데이터를 로드합니다
    }
  }
  
  private func timeString(from date: Date) -> String {
    DateFormatter.hourMinute.string(from: date)
  }
  
  private func showFinishMatchAlert() {
    showSystemAlert(
      title: "해당 경기를 종료할까요?",
      message: "경기가 종료되면 더 이상 인원을 모집할 수 없어요.",
      tint: .systemRed,
      actions: [
        UIAlertAction(title: "취소", style: .cancel) { _ in
          viewModel.isFinishMatchAlertShow = false
        },
        UIAlertAction(title: "종료", style: .destructive) { _ in
          Task { await viewModel.finishSelectedMatch() }
          viewModel.isFinishMatchAlertShow = false
        }
      ]
    )
  }
}

// MARK: - Preview

#Preview {
  NavigationStack {
    CalendarMatchView()
  }
}
