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
    let emptySelector: Selector = "CloudyNoSelector" // Yay Swift ಠ_ಠ

    let nowPlayingItem = NSMenuItem(title: "Now Playing", action: emptySelector, keyEquivalent: "")
    nowPlayingItem.enabled = false
    menu.addItem(nowPlayingItem)

    let showNameItem = item?.show.map({
        let item = NSMenuItem(title: $0, action: emptySelector, keyEquivalent: "")
        item.indentationLevel = 1
        item.enabled = false
        return item
    }) ?? NSMenuItem(title: "Now Show Title", action: emptySelector, keyEquivalent: "")
    menu.addItem(showNameItem)

    let episodeNameItem = item?.episode.map({
        let item = NSMenuItem(title: $0, action: emptySelector, keyEquivalent: "")
        item.indentationLevel = 1
        item.enabled = false
        return item
    }) ?? NSMenuItem(title: "Now Show Title", action: emptySelector, keyEquivalent: "")
    menu.addItem(episodeNameItem)

    menu.addItem(NSMenuItem.separatorItem())

    let togglePlaybackItem = NSMenuItem(title: playing ? "Pause" : "Play", action: "togglePlaybackState:", keyEquivalent: "")
    menu.addItem(togglePlaybackItem)

    return menu
}

@NSApplicationMain final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - NSApplicationDelegate

    func applicationDockMenu(sender: NSApplication) -> NSMenu? {
        return DockMenu(
            item: NowPlayingController.shared().nowPlayingItem,
            playing: NowPlayingController.shared().playing
        )
    }
}
