//
//  NowPlayingController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/21/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import Foundation

private let SharedController = NowPlayingController()

class NowPlayingController: NSObject {

    // MARK: - Properties

    dynamic var playing = false

    dynamic var nowPlayingItem: PlaybackItem?


    // MARK: - Public

    class func shared() -> NowPlayingController {
        return SharedController
    }
}
