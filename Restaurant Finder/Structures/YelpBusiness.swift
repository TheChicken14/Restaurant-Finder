//
//  YelpBusiness.swift
//  Restaurant FInder
//
//  Created by Wisse Hes on 02/08/2021.
//

import Foundation
import Alamofire

// MARK: - YelpBusinessResponse

struct YelpBusinessResponse: Codable {
    let businesses: [YelpBusiness]
    let total: Int
}

// MARK: - YelpBusiness
struct YelpBusiness: Codable {
    let id, alias, name: String
    let imageURL: String
    let isClosed: Bool
    let url: String
    let reviewCount: Int
    let categories: [Category]
    let rating: Double
    let coordinates: Coordinates
//    let transactions: [JSONAny]
    let location: Location
    let phone, displayPhone: String
    let distance: Double

    enum CodingKeys: String, CodingKey {
        case id, alias, name
        case imageURL = "image_url"
        case isClosed = "is_closed"
        case url
        case reviewCount = "review_count"
        case categories, rating, coordinates, location, phone
        case displayPhone = "display_phone"
        case distance
    }
}

// MARK: - Category
struct Category: Codable {
    let alias, title: String
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude, longitude: Double
}

// MARK: - Location
struct Location: Codable {
    let address1: String
//    let address2: JSONNull?
//    let address3: String
    let city, zipCode, country: String
    let state: String
    let displayAddress: [String]

    enum CodingKeys: String, CodingKey {
        case address1, city
        case zipCode = "zip_code"
        case country, state
        case displayAddress = "display_address"
    }
}
