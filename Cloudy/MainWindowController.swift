//
//  MainWindowController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import Cocoa
import ReactiveCocoa

final class MainWindowController: NSWindowController {

    // MARK: - Properties

    @IBOutlet private var navigationControl: NSSegmentedControl!

    @IBOutlet private var shareButton: NSButton!

    @IBOutlet private var playbackButton: NSButton!

    @IBOutlet private var loadingIndicator: NSProgressIndicator!

    private var playbackViewController: PlaybackViewController! {
        return contentViewController as? PlaybackViewController
    }


    // MARK: - NSWindowController

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.titleVisibility = .Hidden
        window?.excludedFromWindowsMenu = true
        shareButton.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        playbackButton.imagePosition = .ImageLeft

        playbackViewController.nowPlayingItem.producer
            .map({ $0?.compositeTitle ?? "Cloudy: Nothing Playing" })
            .startWithNext({ [weak self] in
                self?.playbackButton.title = $0
            })

        playbackViewController.nowPlayingItem.producer
            .map({ $0?.compositeTitle ?? "Cloudy" })
            .startWithNext({ [weak self] in
                self?.window?.title = $0
            })

        playbackViewController.nowPlayingItem.producer
            .map({ $0 != nil })
            .startWithNext({ [weak self] enabled in
                self?.shareButton.enabled = enabled
                self?.playbackButton.enabled = enabled
            })

        playbackViewController.nowPlayingItem.producer
            .combineLatestWith(playbackViewController.isPlaying.producer)
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

        playbackViewController.webViewCanGoBack.startWithNext({ [weak self] in
            self?.navigationControl.setEnabled($0, forSegment: 0)
        })

        playbackViewController.webViewCanGoForward.startWithNext({ [weak self] in
            self?.navigationControl.setEnabled($0, forSegment: 1)
        })

        playbackViewController.webViewLoading.startWithNext({ [weak self] in
            guard let indicator = self?.loadingIndicator else { return }
            if $0 { indicator.startAnimation(nil) }
            else { indicator.stopAnimation(nil) }
        })
    }
}

extension MainWindowController: NSWindowDelegate {
    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
