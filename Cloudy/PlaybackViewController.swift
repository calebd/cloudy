//
//  PlaybackViewController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
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


    // MARK: - Public

    func togglePlaybackState(sender: AnyObject?) {
        webView.evaluateJavaScript("Cloudy.togglePlaybackState();", completionHandler: nil)
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
        NowPlayingController.shared().nowPlayingItem = dictionary.map({ PlaybackItem(episodeDictionary: $0) })
    }

    private func handleUpdatePlaybackMessage(message: AnyObject?) {
        NowPlayingController.shared().playing = message as? Bool ?? false
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
        picker.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSMinYEdge)
    }

    @objc private func reloadPage(sender: AnyObject?) {
        webView.reload()
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
