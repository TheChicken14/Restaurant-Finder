//
//  YelpRating.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 06/08/2021.
//

import Foundation

enum YelpRating: Double {
    case rating0 = 0.0
    case rating1 = 1.0
    case rating1half = 1.5
    case rating2 = 2.0
    case rating2half = 2.5
    case rating3 = 3.0
    case rating3half = 3.5
    case rating4 = 4.0
    case rating4half = 4.5
    case rating5 = 5.0
    
    func getImageName() -> String {
        switch self {
            
        case .rating0:
            return "rating_0"
        case .rating1:
            return "rating_1"
        case .rating1half:
            return "rating_1_half"
        case .rating2:
            return "rating_2"
        case .rating2half:
            return "rating_2_half"
        case .rating3:
            return "rating_3"
        case .rating3half:
            return "rating_3_half"
        case .rating4:
            return "rating_4"
        case .rating4half:
            return "rating_4_half"
        case .rating5:
            return "rating_5"
        }
    }
}
