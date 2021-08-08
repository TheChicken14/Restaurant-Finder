//
//  EnvironmentValues+ImageCache.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 08/08/2021.
//
// from https://github.com/V8tr/AsyncImage/blob/master/AsyncImage/EnvironmentValues%2BImageCache.swift

import SwiftUI

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
