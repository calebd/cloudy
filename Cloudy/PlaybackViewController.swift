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

    private let webView: WKWebView = {
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
        println("\(__FUNCTION__) \(dictionary)")
    }

    private func handleUpdatePlaybackMessage(message: AnyObject?) {
        let dictionary = message as? [String: AnyObject]
        println("\(__FUNCTION__) \(dictionary)")
    }

    @objc private func play(sender: AnyObject?) {
        webView.evaluateJavaScript("Cloudy.play();", completionHandler: nil)
    }

    @objc private func pause(sender: AnyObject?) {
        webView.evaluateJavaScript("Cloudy.pause();", completionHandler: nil)
    }

    @objc private func goBack(sender: AnyObject?) {
        webView.goBack()
    }

    @objc private func goForward(sender: AnyObject?) {
        webView.goForward()
    }

    @objc private func share(sender: AnyObject?) {
        
    }


    // MARK: - WKNavigationDelegate

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        println("\(__FUNCTION__) \(webView.URL)")
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

