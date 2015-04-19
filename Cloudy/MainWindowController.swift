//
//  MainWindowController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import Cocoa
import ReactiveCocoa

final class MainWindowController: NSWindowController, NSWindowDelegate {

    // MARK: - Properties

    @IBOutlet var navigationControl: NSSegmentedControl?

    @IBOutlet var shareButton: NSButton?

    @IBOutlet var playbackButton: NSButton?


    // MARK: - NSWindowController

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .Hidden
        shareButton?.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        playbackButton?.imagePosition = .ImageLeft

        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
            rac_valuesForKeyPath("contentViewController.webView.canGoBack", observer: self),
            RACSignal.`return`(0)
        ])

        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
            rac_valuesForKeyPath("contentViewController.webView.canGoForward", observer: self),
            RACSignal.`return`(1)
        ])

        rac_valuesForKeyPath("contentViewController.currentPlaybackItem", observer: self)
            .map({ $0 is PlaybackItem })
            .setKeyPath("shareButton.enabled", onObject: self)

        rac_valuesForKeyPath("contentViewController.currentPlaybackItem", observer: self)
            .map({ $0 is PlaybackItem })
            .setKeyPath("playbackButton.enabled", onObject: self)

        rac_valuesForKeyPath("contentViewController.currentPlaybackItem", observer: self)
            .map({
                let item = $0 as? PlaybackItem
                return item?.prettyName() ?? "Cloudy: No Episode"
            })
            .setKeyPath("playbackButton.title", onObject: self)

        let playbackButtonImageSignals = [
            rac_valuesForKeyPath("contentViewController.currentPlaybackItem", observer: self).map({ $0 is PlaybackItem }),
            rac_valuesForKeyPath("contentViewController.isPlaying", observer: self)
        ]
        RACSignal.combineLatest(playbackButtonImageSignals)
            .map({
                let tuple = $0 as! RACTuple
                let isEpisodePage = tuple.first as! Bool
                let isPlaying = tuple.second as! Bool
                if isEpisodePage {
                    return isPlaying ? NSImage(named: "pause") : NSImage(named: "play")
                }
                return nil
            })
            .setKeyPath("playbackButton.image", onObject: self)
    }


    // MARK: - NSWindowDelegate

    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
