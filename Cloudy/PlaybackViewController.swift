//
//  PlaybackViewController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Shiny Bits. All rights reserved.
//

import Cocoa
import WebKit

final class PlaybackViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {

    // MARK: - Properties

    private dynamic let webView: WKWebView = {
        let script: WKUserScript = {
            let url = NSBundle.mainBundle().URLForResource("cloudy", withExtension: "js")!
            let contents = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil)!
            return WKUserScript(source: contents, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        }()

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(script)

        #if DEBUG
            configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        let view = WKWebView(frame: CGRectZero, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private(set) dynamic var isPlaying: Bool = false

    private(set) dynamic var currentPlaybackItem: PlaybackItem?


    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.configuration.userContentController.addScriptMessageHandler(self, name: "playbackHandler")
        webView.configuration.userContentController.addScriptMessageHandler(self, name: "episodeHandler")
        webView.navigationDelegate = self

        view.addSubview(webView)
        setupConstraints()

        let url = NSURL(string: "https://overcast.fm")
        let request = url.map({ NSURLRequest(URL: $0) })
        request.map({ webView.loadRequest($0) })
    }


    // MARK: - Private

    private func setupConstraints() {
        let views = [
            "webView": webView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[webView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: views))
    }

    private func handleUpdateEpisodeMessage(message: AnyObject?) {
        let dictionary = message as? [String: AnyObject]
        currentPlaybackItem = dictionary.map({ PlaybackItem(episodeDictionary: $0) })
        title = currentPlaybackItem?.prettyName()
    }

    private func handleUpdatePlaybackMessage(message: AnyObject?) {
        let dictionary = message as! [String: AnyObject]
        isPlaying = dictionary["is_playing"] as? Bool ?? false
    }

    @objc private func performBrowserNavigation(sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            webView.goBack()
        case 1:
            webView.goForward()
        default:
            noop()
        }
    }

    @objc private func togglePlaybackState(sender: AnyObject?) {
        webView.evaluateJavaScript("Cloudy.togglePlaybackState();", completionHandler: nil)
    }

    @objc private func share(sender: NSButton) {
        var items = [AnyObject]()

        currentPlaybackItem?.prettyName().map({ items.append($0) })
        webView.URL.map({ items.append($0) })

        if items.count == 0 {
            return
        }

        let picker = NSSharingServicePicker(items: items)
        picker.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSMinYEdge)
    }


    // MARK: - WKNavigationDelegate

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .LinkActivated {
            let host = navigationAction.request.URL?.host
            let policy: WKNavigationActionPolicy = host == "overcast.fm" ? .Allow : .Cancel
            decisionHandler(policy)
        }
        decisionHandler(.Allow)
    }


    // MARK: - WKScriptMessageHandler

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        switch message.name {
        case "episodeHandler":
            handleUpdateEpisodeMessage(message.body)
        case "playbackHandler":
            handleUpdatePlaybackMessage(message.body)
        default:
            noop()
        }
    }
}
