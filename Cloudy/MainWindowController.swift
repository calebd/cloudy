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

    @IBOutlet var loadingIndicator: NSProgressIndicator?


    // MARK: - NSWindowController

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.titleVisibility = .Hidden
        window?.excludedFromWindowsMenu = true
        shareButton?.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        playbackButton?.imagePosition = .ImageLeft
//
//        let nowPlayingItemSignal = NowPlayingController.shared().rac_valuesForKeyPath("nowPlayingItem", observer: self)
//        let hasNowPlayingItemSignal = nowPlayingItemSignal.map({ $0 is PlaybackItem })
//        let isPlayingSignal = NowPlayingController.shared().rac_valuesForKeyPath("playing", observer: self)
//
//        hasNowPlayingItemSignal.setKeyPath("shareButton.enabled", onObject: self)
//        hasNowPlayingItemSignal.setKeyPath("playbackButton.enabled", onObject: self)
//
//        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
//            rac_valuesForKeyPath("contentViewController.webView.canGoBack", observer: self),
//            RACSignal.`return`(0)
//        ])
//
//        navigationControl?.rac_liftSelector("setEnabled:forSegment:", withSignalsFromArray: [
//            rac_valuesForKeyPath("contentViewController.webView.canGoForward", observer: self),
//            RACSignal.`return`(1)
//        ])
//
//        nowPlayingItemSignal
//            .map({
//                let item = $0 as? PlaybackItem
//                return item?.prettyName() ?? "Cloudy: Nothing Playing"
//            })
//            .setKeyPath("playbackButton.title", onObject: self)
//
//        nowPlayingItemSignal
//            .map({
//                let item = $0 as? PlaybackItem
//                return item?.prettyName() ?? "Cloudy"
//            })
//            .setKeyPath("window.title", onObject: self)
//
//        let playbackButtonImageSignals = [ hasNowPlayingItemSignal, isPlayingSignal ]
//        RACSignal.combineLatest(playbackButtonImageSignals)
//            .map({
//                let tuple = $0 as! RACTuple
//                let hasNowPlayingItem = tuple.first as! Bool
//                let isPlaying = tuple.second as! Bool
//                switch (hasNowPlayingItem, isPlaying) {
//                case (true, true):
//                    return NSImage(named: "pause")
//                case (true, false):
//                    return NSImage(named: "play")
//                default:
//                    return nil
//                }
//            })
//            .setKeyPath("playbackButton.image", onObject: self)
//
//        rac_liftSelector("webViewLoadingDidChange:", withSignalsFromArray: [
//            rac_valuesForKeyPath("contentViewController.webView.loading", observer: self)
//        ])
    }


    // MARK: - Private

    @objc private func webViewLoadingDidChange(loading: Bool) {
        if loading {
            loadingIndicator?.startAnimation(self)
        }
        else {
            loadingIndicator?.stopAnimation(self)
        }
    }


    // MARK: - NSWindowDelegate

    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
