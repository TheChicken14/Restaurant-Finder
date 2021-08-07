//
//  YelpParams.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 02/08/2021.
//

import Foundation

struct YelpParams: Encodable {
    var location: String
    var categories: String
    var term: String? = nil
}
