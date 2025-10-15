//
//  UserRating.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/13/25.
//

import Foundation

struct UserRating: Codable, Equatable, Hashable {
    var totalRatingCount: Int
    var mannerSum: Double
    var teamWorkSum: Double
    var appointmentSum: Double
}
