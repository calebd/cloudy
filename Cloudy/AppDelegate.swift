//
//  AppDelegate.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import Cocoa

private func DockMenu(#item: PlaybackItem?, #playing: Bool) -> NSMenu? {
    if item == nil {
        return nil
    }

    let menu = NSMenu()
    menu.autoenablesItems = false

    let nowPlayingItem = NSMenuItem()
    nowPlayingItem.title = "Now Playing"
    nowPlayingItem.enabled = false
    menu.addItem(nowPlayingItem)

    let showNameItem = NSMenuItem()
    showNameItem.title = item?.show ?? "Now Show Title"
    showNameItem.indentationLevel = 1
    showNameItem.enabled = false
    menu.addItem(showNameItem)

    let episodeNameItem = NSMenuItem()
    episodeNameItem.title = item?.episode ?? "Now Episode Title"
    episodeNameItem.indentationLevel = 1
    episodeNameItem.enabled = false
    menu.addItem(episodeNameItem)

    menu.addItem(NSMenuItem.separatorItem())

    let togglePlaybackItem = NSMenuItem(title: playing ? "Pause" : "Play", action: "togglePlaybackState:", keyEquivalent: "")
    menu.addItem(togglePlaybackItem)

    return menu
}

private func GetPlaybackViewController() -> PlaybackViewController? {
    let windows = NSApplication.sharedApplication().windows as? [NSWindow] ?? []
    for window in windows {
        if let controller = window.contentViewController as? PlaybackViewController {
            return controller
        }
    }
    return nil
}

@NSApplicationMain final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - NSApplicationDelegate

    func applicationDockMenu(sender: NSApplication) -> NSMenu? {
        return DockMenu(
            item: NowPlayingController.shared().nowPlayingItem,
            playing: NowPlayingController.shared().playing
        )
    }


    // MARK: - Private

    @objc private func togglePlaybackState(sender: AnyObject?) {
        GetPlaybackViewController()?.togglePlaybackState(self)
    }
}
