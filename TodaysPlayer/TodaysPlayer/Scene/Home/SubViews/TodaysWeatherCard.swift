//
//  TodaysWeatherCard.swift
//  TodaysPlayer
//
//  Created by J on 10/17/25.
//

import SwiftUI
import WeatherKit

struct TodaysWeatherCard: View {
    let weatherData: Weather?
    let isLoading: Bool
    let hasError: Bool
    
    var body: some View {
        Group {
            if let weather = weatherData {
                weatherContentView(weather: weather)
            } else if isLoading {
                weatherLoadingView()
            } else if hasError {
                weatherErrorView()
            } else {
                weatherLoadingView()
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func weatherContentView(weather: Weather) -> some View {
        VStack(spacing: 10) {
            // 타이틀 및 심볼
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.red)
                        
                        Text("오늘의 날씨")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        
                        Spacer()
                    }
                    
                    Text("경기 전 날씨를 확인해보세요")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
                
                Image(systemName: weather.currentWeather.symbolName)
                    .font(.system(size: 70))
                    .foregroundStyle(getWeatherColor(weather.currentWeather.condition))
                    .padding(.top, 10)
                    .padding(.trailing, 5)
            }
            .padding(.top, 6)
            
            // (온도, 기상) 정보
            HStack(spacing: 15) {
                Text("\(Int(weather.currentWeather.temperature.value))°")
                    .font(.system(size: 50))
                    .fontWeight(.semibold)
                
                Text(getKoreanCondition(weather.currentWeather.condition))
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .padding(.leading, 10)
            
            // (강수, 바람, 습도) 정보
            HStack(spacing: 30) {
                HStack {
                    Image(systemName: "cloud.rain")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue.opacity(0.6))
                    
                    Text("강수 확률\n\(Int(getPrecipitationChance(weather) * 100.0))%")
                        .font(.system(size: 15))
                        .foregroundStyle(.black.opacity(0.7))
                }
                
                HStack {
                    Image(systemName: "wind")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    
                    Text("바람\n\(Int(weather.currentWeather.wind.speed.value))m/s")
                        .font(.system(size: 15))
                        .foregroundStyle(.black.opacity(0.7))
                }
                
                HStack {
                    Image(systemName: "drop.halffull")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                    
                    Text("습도\n\(Int(weather.currentWeather.humidity * 100))%")
                        .font(.system(size: 15))
                        .foregroundStyle(.black.opacity(0.7))
                }
            }
            .padding(.vertical, 10)
            
            HStack {
                Text(getWeatherMessage(weather: weather))
                    .font(.system(size: 16))
                    .foregroundStyle(.black.opacity(0.8))
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.futsalGreen, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func weatherLoadingView() -> some View {
        VStack(spacing: 15) {
            // 타이틀 및 심볼
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.red)
                        
                        Text("오늘의 날씨")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        
                        Spacer()
                    }
                    
                    Text("데이터를 불러오는 중입니다")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
                
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.blue)
            }
            .padding(.top, 16)
            
            // 로딩 메시지
            VStack(spacing: 10) {
                Text("날씨 정보를 가져오고 있어요")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
                Text("잠시만 기다려주세요")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 20)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func weatherErrorView() -> some View {
        VStack(spacing: 15) {
            // 타이틀 및 심볼
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.red)
                        
                        Text("오늘의 날씨")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        
                        Spacer()
                    }
                    
                    Text("날씨 정보를 불러올 수 없습니다")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
            }
            .padding(.top, 16)
            
            // 에러 메시지
            VStack(spacing: 10) {
                Text("날씨 데이터를 받아올 수 없습니다.")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
                Text("위치 권한을 확인하거나,\n잠시 후 다시 시도해주세요")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            
            Spacer()
        }
    }
}

extension TodaysWeatherCard {
    private func getPrecipitationChance(_ weather: Weather) -> Double {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // 1~5시간 후의 시간대를 찾아서 강수확률 계산
        let targetHours = [currentHour, currentHour + 5]
        var maxProbability: Double = 0.0
        
        // hourlyForecast에서 해당 시간대들을 찾아서 최대 강수확률을 반환
        for forecast in weather.hourlyForecast.prefix(24) { // 최대 24시간까지만 확인
            let forecastHour = Calendar.current.component(.hour, from: forecast.date)
            
            if targetHours.contains(forecastHour) {
                maxProbability = max(maxProbability, forecast.precipitationChance)
            }
        }
        
        return maxProbability
    }
    
    private func getKoreanCondition(_ condition: WeatherCondition) -> String {
        switch condition {
        case .blizzard:
            return "눈보라"
        case .blowingDust:
            return "먼지바람"
        case .blowingSnow:
            return "눈바람"
        case .breezy:
            return "바람"
        case .clear:
            return "맑음"
        case .cloudy:
            return "흐림"
        case .drizzle:
            return "이슬비"
        case .flurries:
            return "눈발"
        case .foggy:
            return "안개"
        case .freezingDrizzle:
            return "얼어붙는 이슬비"
        case .freezingRain:
            return "얼어붙는 비"
        case .frigid:
            return "매우 추움"
        case .hail:
            return "우박"
        case .haze:
            return "실안개"
        case .heavyRain:
            return "폭우"
        case .heavySnow:
            return "폭설"
        case .hot:
            return "더움"
        case .hurricane:
            return "허리케인"
        case .isolatedThunderstorms:
            return "국지적 뇌우"
        case .mostlyClear:
            return "대체로 맑음"
        case .mostlyCloudy:
            return "대체로 흐림"
        case .partlyCloudy:
            return "구름 조금"
        case .rain:
            return "비"
        case .scatteredThunderstorms:
            return "산발적 뇌우"
        case .sleet:
            return "진눈깨비"
        case .smoky:
            return "연기"
        case .snow:
            return "눈"
        case .strongStorms:
            return "강한 폭풍"
        case .sunFlurries:
            return "눈발과 맑음"
        case .sunShowers:
            return "소나기"
        case .thunderstorms:
            return "뇌우"
        case .tropicalStorm:
            return "열대 폭풍"
        case .windy:
            return "강풍"
        case .wintryMix:
            return "겨울 혼합 강수"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    private func getWeatherColor(_ condition: WeatherCondition) -> Color {
        switch condition {
        case .clear, .mostlyClear:
            return .orange
        case .partlyCloudy, .mostlyCloudy:
            return .gray
        case .cloudy:
            return .gray.opacity(0.7)
        case .rain, .drizzle, .sunShowers:
            return .blue
        case .thunderstorms, .scatteredThunderstorms, .isolatedThunderstorms, .strongStorms:
            return .purple
        case .snow, .blizzard, .sleet, .hail, .freezingDrizzle, .freezingRain, .heavySnow, .flurries, .sunFlurries, .wintryMix, .blowingSnow:
            return .cyan
        case .foggy, .haze:
            return .gray.opacity(0.5)
        case .breezy, .windy:
            return .green
        case .hot, .frigid:
            return condition == .hot ? .red : .blue
        case .heavyRain:
            return .blue.opacity(0.8)
        case .blowingDust, .smoky:
            return .brown
        case .hurricane, .tropicalStorm:
            return .red
        default:
            return .gray
        }
    }
    
    private func getWeatherMessage(weather: Weather) -> String {
        let temp = weather.currentWeather.temperature.value
        let condition = weather.currentWeather.condition
        
        let precipitationChance = getPrecipitationChance(weather)
        
        // 비 관련 날씨
        if condition == .rain || condition == .drizzle || condition == .sunShowers ||
            condition == .heavyRain || condition == .freezingRain || precipitationChance > 0.5 {
            return "비가 올 예정이에요 ☔️"
        }
        
        // 뇌우 관련 날씨
        if condition == .thunderstorms || condition == .scatteredThunderstorms ||
           condition == .isolatedThunderstorms || condition == .strongStorms {
            return "뇌우 주의하세요! ⛈️"
        }
        
        // 눈 관련 날씨
        if condition == .snow || condition == .blizzard || condition == .sleet ||
           condition == .flurries || condition == .sunFlurries || condition == .wintryMix ||
           condition == .blowingSnow {
            return "눈이 오네요! 미끄럼 주의하세요 ⛄️"
        }
        
        // 얼음 관련 날씨
        if condition == .hail || condition == .freezingDrizzle {
            return "얼음 주의하세요! 🧊"
        }
        
        // 온도별 메시지
        if temp < 15 {
            return "추운 날씨에요! 따뜻하게 입으세요 🧥"
        } else if temp > 30 {
            return "더운 날씨에요! 충분한 수분 섭취하세요 🥤"
        }
        
        // 맑은 날씨
        if condition == .clear || condition == .mostlyClear {
            return "경기하기 좋은 날씨에요~! ⚽️"
        }
        
        // 구름 있는 날씨
        if condition == .partlyCloudy || condition == .mostlyCloudy || condition == .cloudy {
            return "구름이 있지만 경기하기 좋아요! ☁️"
        }
        
        // 바람 관련
        if condition == .breezy || condition == .windy || condition == .blowingDust {
            return "바람이 불어요! 💨"
        }
        
        // 안개/실안개
        if condition == .foggy || condition == .haze || condition == .smoky {
            return "시야가 흐려요! 주의하세요 🌫️"
        }
        
        // 극한 날씨
        if condition == .hurricane || condition == .tropicalStorm {
            return "폭풍 주의! 외출을 피하세요 🌀"
        }
        
        // 기본 메시지
        return "날씨를 확인하고 경기하세요 🌤️"
    }
}
