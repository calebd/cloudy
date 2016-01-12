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

    @IBOutlet private var shareButton: NSButton!

    @IBOutlet private var playbackButton: NSButton!

    @IBOutlet var loadingIndicator: NSProgressIndicator?


    // MARK: - NSWindowController

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.titleVisibility = .Hidden
        window?.excludedFromWindowsMenu = true
        shareButton.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        playbackButton.imagePosition = .ImageLeft

        let playbackController = contentViewController as! PlaybackViewController

        playbackController.nowPlayingItem.producer
            .map({ item -> String in
                switch item {
                case let item?:
                    return "\(item.showName): \(item.episodeName)"
                case .None:
                    return "Cloudy: Nothing Playing"
                }
            })
            .startWithNext({ [weak self] thing in
                self?.playbackButton.title = thing
            })

        playbackController.nowPlayingItem.producer
            .combineLatestWith(playbackController.isPlaying.producer)
            .map({ nowPlayingItem, isPlaying -> NSImage? in
                switch (nowPlayingItem, isPlaying) {
                case (.Some, true):
                    return NSImage(named: "pause")
                case (.Some, false):
                    return NSImage(named: "play")
                default:
                    return nil
                }
            })
            .startWithNext({ [weak self] image in
                self?.playbackButton.image = image
            })

        playbackController.nowPlayingItem.producer
            .map({ $0 != nil })
            .startWithNext({ [weak self] enabled in
                self?.shareButton.enabled = enabled
                self?.playbackButton.enabled = enabled
            })
//
//        let nowPlayingItemSignal = NowPlayingController.shared().rac_valuesForKeyPath("nowPlayingItem", observer: self)
//        let hasNowPlayingItemSignal = nowPlayingItemSignal.map({ $0 is PlaybackItem })
//        let isPlayingSignal = NowPlayingController.shared().rac_valuesForKeyPath("playing", observer: self)
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
//                return item?.prettyName() ?? "Cloudy"
//            })
//            .setKeyPath("window.title", onObject: self)
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
