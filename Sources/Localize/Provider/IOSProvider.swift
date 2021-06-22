//
//  IOSProvider.swift
//
//
//  Created by Yume on 2021/6/22.
//

import Foundation
import Path

/// zh-Hant.lproj/Localizable.strings
public struct IOSProvider: LanguageProvider {
    public let sources: Source
    private let path: Path
    
    init(_ path: String) {
        self.path = Path(path) ?? Path.cwd/path

        let dirs = self.path.find().depth(max: 1).`extension`("lproj").type(.directory)
        self.sources = IOSProvider.parse(dirs)
    }
    
    private static func parse(_ finder: Path.Finder) -> Source {
        var source: Source = [:]
        
        finder.forEach { path in
            let lang = path.basename(dropExtension: true)
            source[lang] = self.mapping(path)
        }

        return source
    }
    
    private static func mapping(_ path: Path) -> Mapping {
        let targetFile = path/"Localizable.strings"
        let dict = NSDictionary(contentsOf: targetFile.url) as? [String: String]
        return dict ?? [:]
    }
}
