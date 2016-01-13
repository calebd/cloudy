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
import ReactiveCocoa

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
        configuration.userContentController.addScriptMessageHandler(self, name: "playbackHandler")
        configuration.userContentController.addScriptMessageHandler(self, name: "episodeHandler")
        configuration.userContentController.addScriptMessageHandler(self, name: "unplayedEpisodeCountHandler")

        #if DEBUG
            configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.autoresizingMask = [ .ViewWidthSizable, .ViewHeightSizable ]
        view.navigationDelegate = self
        return view
    }()

    private let _nowPlayingItem = MutableProperty<MediaItem?>(nil)

    private let _unplayedEpisodeCount = MutableProperty<Int>(0)

    private let _isPlaying = MutableProperty<Bool>(false)

    var nowPlayingItem: AnyProperty<MediaItem?> {
        return AnyProperty(_nowPlayingItem)
    }

    var unplayedEpisodeCount: AnyProperty<Int> {
        return AnyProperty(_unplayedEpisodeCount)
    }

    var isPlaying: AnyProperty<Bool> {
        return AnyProperty(_isPlaying)
    }

    var webViewCanGoBack: SignalProducer<Bool, NoError> {
        return DynamicProperty(object: webView, keyPath: "canGoBack").producer.map({ $0 as? Bool }).ignoreNil()
    }

    var webViewCanGoForward: SignalProducer<Bool, NoError> {
        return DynamicProperty(object: webView, keyPath: "canGoForward").producer.map({ $0 as? Bool }).ignoreNil()
    }

    var webViewLoading: SignalProducer<Bool, NoError> {
        return DynamicProperty(object: webView, keyPath: "loading").producer.map({ $0 as? Bool }).ignoreNil()
    }


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
        if let item = nowPlayingItem.value?.compositeTitle {
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

    @objc private func reload(_: AnyObject?) {
        webView.reload()
    }

    @objc private func togglePlaybackState(_: AnyObject?) {
        webView.evaluateJavaScript("Cloudy.togglePlaybackState();", completionHandler: nil)
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
        switch (message.name, message.body) {
        case ("episodeHandler", let body as [String: String]):
            _nowPlayingItem.value = MediaItem(dictionary: body)
        case ("episodeHandler", _):
            _nowPlayingItem.value = nil
        case ("playbackHandler", let body as Bool):
            _isPlaying.value = body
        case ("unplayedEpisodeCountHandler", let body as Int):
            _unplayedEpisodeCount.value = body
        default:
            ()
        }
    }
}

extension PlaybackViewController {
    struct MediaItem {
        var showTitle: String
        var episodeTitle: String

        var compositeTitle: String {
            return "\(showTitle): \(episodeTitle)"
        }

        init?(dictionary: [String: String]) {
            guard
                let showName = dictionary["show_title"],
                let episodeName = dictionary["episode_title"]
            else {
                return nil
            }

            self.showTitle = showName
            self.episodeTitle = episodeName
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
//    // MARK: - Private
//
//    private func seekBackward() {
//        webView.evaluateJavaScript("Cloudy.seekBackward();", completionHandler: nil)
//    }
//
//    private func seekForward() {
//        webView.evaluateJavaScript("Cloudy.seekForward();", completionHandler: nil)
//    }
//}
