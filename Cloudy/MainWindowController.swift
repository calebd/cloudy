//
//  MainWindowController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Shiny Bits. All rights reserved.
//

import Cocoa

final class MainWindowController: NSWindowController, NSWindowDelegate {

    // MARK: - NSWindowController

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .Hidden
    }


    // MARK: - NSWindowDelegate

    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().terminate(self)
        return false
    }
}
