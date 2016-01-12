//
//  PlaybackViewController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import Cocoa
import MediaKeys
import WebKit

final class PlaybackViewController: NSViewController {

    // MARK: - Properties

    private lazy var webView: WKWebView = {
        let script: WKUserScript = {
            let URL = NSBundle.mainBundle().URLForResource("cloudy", withExtension: "js")!
            let contents =  try! String(contentsOfURL: URL, encoding: NSUTF8StringEncoding)
            return WKUserScript(source: contents, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        }()

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(script)

        #if DEBUG
            configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.autoresizingMask = [ .ViewWidthSizable, .ViewHeightSizable ]
        view.configuration.userContentController.addScriptMessageHandler(self, name: "playbackHandler")
        view.configuration.userContentController.addScriptMessageHandler(self, name: "episodeHandler")
        view.configuration.userContentController.addScriptMessageHandler(self, name: "unplayedEpisodeCountHandler")
        view.navigationDelegate = self
        return view
    }()


    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.bounds
        view.addSubview(webView)

        let URL = NSURL(string: "https://overcast.fm")!
        let request = NSURLRequest(URL: URL)
        webView.loadRequest(request)
    }


    // MARK: - Private

    @objc private func navigate(sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            webView.goBack()
        case 1:
            webView.goForward()
        default:
            ()
        }
    }

    @objc private func share(sender: NSButton) {

        // Build items
        var items = [AnyObject]()
        if let item = NowPlayingController.shared().nowPlayingItem?.prettyName() {
            items.append(item)
        }
        if let item = webView.URL {
            items.append(item)
        }
        if items.count == 0 {
            return
        }

        // Show picker
        let picker = NSSharingServicePicker(items: items)
        picker.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: .MinY)
    }

    @objc private func reload() {
        webView.reload()
    }
}

extension PlaybackViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .LinkActivated {
            let host = navigationAction.request.URL?.host
            let policy: WKNavigationActionPolicy = host == "overcast.fm" ? .Allow : .Cancel
            decisionHandler(policy)
        }
        decisionHandler(.Allow)
    }
}

extension PlaybackViewController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        switch message.name {
        case "episodeHandler":
            ()
        case "playbackHandler":
            ()
        case "unplayedEpisodeCountHandler":
            ()
        default:
            noop()
        }
    }
}

//final class PlaybackViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {
//
//    // MARK: - Properties
//
//    private let mediaKeys = MediaKeys()
//
//
//    // MARK: - NSViewController
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        mediaKeys.watch({ [unowned self] key in
//            switch key {
//            case .PlayPause:
//                self.togglePlaybackState(nil)
//            case .Forward:
//                self.seekForward()
//            case .Rewind:
//                self.seekBackward()
//            }
//        })
//    }
//
//
//    // MARK: - Public
//
//    func togglePlaybackState(sender: AnyObject?) {
//        webView.evaluateJavaScript("Cloudy.togglePlaybackState();", completionHandler: nil)
//    }
//
//
//    // MARK: - Private
//
//    private func handleUpdateEpisodeMessage(message: AnyObject?) {
//        let dictionary = message as? [String: AnyObject]
//        NowPlayingController.shared().nowPlayingItem = dictionary.map({ PlaybackItem(episodeDictionary: $0) })
//    }
//
//    private func handleUpdatePlaybackMessage(message: AnyObject?) {
//        NowPlayingController.shared().playing = message as? Bool ?? false
//    }
//
//    private func handleUnplayedEpisodeCountMessage(message: AnyObject?) {
//        if let count = message as? Int {
//            NSApplication.sharedApplication().dockTile.badgeLabel = String(count)
//        }
//    }
//
//    private func seekBackward() {
//        webView.evaluateJavaScript("Cloudy.seekBackward();", completionHandler: nil)
//    }
//
//    private func seekForward() {
//        webView.evaluateJavaScript("Cloudy.seekForward();", completionHandler: nil)
//    }
//}
