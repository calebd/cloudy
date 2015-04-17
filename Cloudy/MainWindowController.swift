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
    }


    // MARK: - NSWindowDelegate

    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
