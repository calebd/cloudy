//
//  Cloudy.swift
//  Cloudy
//
//  Created by Caleb Davenport on 1/12/16.
//  Copyright © 2016 Caleb Davenport. All rights reserved.
//

import WebKit
import ReactiveCocoa

extension WKWebView {
    final var canGoBackProducer: SignalProducer<Bool, NoError> {
        return DynamicProperty(object: self, keyPath: "canGoBack").producer.map({ $0 as! Bool })
    }

    final var canGoForwardProducer: SignalProducer<Bool, NoError> {
        return DynamicProperty(object: self, keyPath: "canGoForward").producer.map({ $0 as! Bool })
    }

    final var loadingProducer: SignalProducer<Bool, NoError> {
        return DynamicProperty(object: self, keyPath: "loading").producer.map({ $0 as! Bool })
    }
}
