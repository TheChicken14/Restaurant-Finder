//
//  YelpParams.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 02/08/2021.
//

import Foundation

struct YelpParams: Encodable {
    let location: String
    let categories: String
    let term: String? = nil
}
