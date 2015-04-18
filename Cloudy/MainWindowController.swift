//
//  MainWindowController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Shiny Bits. All rights reserved.
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
        shareButton?.sendActionOn(Int(NSEventMask.LeftMouseUpMask.rawValue))
        playbackButton?.imagePosition = .ImageLeft

        let currentPlaybackItemSignal = rac_valuesForKeyPath("contentViewController.currentPlaybackItem", observer: self)

        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
            rac_valuesForKeyPath("contentViewController.webView.canGoBack", observer: self),
            RACSignal.`return`(0)
        ])

        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
            rac_valuesForKeyPath("contentViewController.webView.canGoForward", observer: self),
            RACSignal.`return`(1)
        ])

        currentPlaybackItemSignal
            .map({ $0 is PlaybackItem })
            .setKeyPath("shareButton.enabled", onObject: self)

        currentPlaybackItemSignal
            .map({ $0 is PlaybackItem })
            .setKeyPath("playbackButton.enabled", onObject: self)

        currentPlaybackItemSignal
            .map({
                let item = $0 as? PlaybackItem
                return item?.prettyName() ?? "Cloudy: No Episode"
            })
            .setKeyPath("playbackButton.title", onObject: self)
    }


    // MARK: - NSWindowDelegate

    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
