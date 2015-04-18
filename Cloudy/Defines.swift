//
//  Defines.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import Foundation

func noop() {}

class PlaybackItem: NSObject {

    // MARK: - Properties

    let show: String?

    let episode: String?


    // MARK: - Initializers

    init(episodeDictionary dictionary: [String: AnyObject]) {
        show = dictionary["show_title"] as? String
        episode = dictionary["episode_title"] as? String
    }


    // MARK: - Helpers

    func prettyName() -> String? {
        switch (show, episode) {
        case (.Some(let show), .Some(let episode)):
            return "\(show): \(episode)"
        case (.Some(let show), .None):
            return show
        case (.None, .Some(let episode)):
            return episode
        default:
            return nil
        }
    }
}
