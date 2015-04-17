//
//  ViewController.swift
//  Cloudy
//
//  Created by Caleb Davenport on 4/16/15.
//  Copyright (c) 2015 Shiny Bits. All rights reserved.
//

import Cocoa
import WebKit

final class ViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {

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

    func setupConstraints() {
        let views = [
            "webView": webView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[webView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: views))
    }


    // MARK: - WKNavigationDelegate

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        println("\(__FUNCTION__) \(webView.URL)")
    }


    // MARK: - WKScriptMessageHandler

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        switch message.name {
        case "episodeHandler":
            let dictionary = message.body as? [String: AnyObject]
            let showTitle = dictionary?["show_title"] as? String
            let episodeTitle = dictionary?["episode_title"] as? String
            println("\(showTitle) - \(episodeTitle)")
        default:
            noop()
        }
    }
}

