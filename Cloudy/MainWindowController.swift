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

        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
            rac_valuesForKeyPath("contentViewController.webView.canGoBack", observer: self),
            RACSignal.`return`(0)
        ])

        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
            rac_valuesForKeyPath("contentViewController.webView.canGoForward", observer: self),
            RACSignal.`return`(1)
        ])

        rac_valuesForKeyPath("contentViewController.isEpisodePage", observer: self)
            .setKeyPath("shareButton.enabled", onObject: self)

        rac_valuesForKeyPath("contentViewController.isEpisodePage", observer: self)
            .setKeyPath("playbackButton.enabled", onObject: self)

        rac_valuesForKeyPath("contentViewController.isPlaying", observer: self)
            .map({ $0 as! Bool ? "Pause" : "Play" })
            .setKeyPath("playbackButton.title", onObject: self)
    }


    // MARK: - NSWindowDelegate

    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
