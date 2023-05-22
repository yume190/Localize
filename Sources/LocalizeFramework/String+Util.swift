//
//  String+Util.swift
//  
//
//  Created by Yume on 2023/5/11.
//

import Foundation

extension StringProtocol {
    public func appending(prefix: String) -> String {
        prefix + self
    }

    public func appending(suffix: String) -> String {
        self + suffix
    }
}

extension String {
    public func indent(_ count: Int = 1, _ word: String = "    ") -> String {
        let prefix = Array(repeating: word, count: count).joined(separator: "")
        return split(separator: "\n")
            .map { sub in
                sub.appending(prefix: prefix)
            }
            .withNewLine
    }
}

extension Array where Element == String {
    public var withNewLine: String {
        joined(separator: "\n")
    }
}
