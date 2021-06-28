//
//  CSVProvider.swift
//  
//
//  Created by Yume on 2021/6/21.
//

import Foundation
import SwiftCSV

public struct CSVProvider: LanguageProvider {
    public let sources: Source
    
    public init(_ csv: CSV) {
        self.sources = CSVProvider.parse(csv)
    }
    
    public init(_ filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        let csv = try CSV(url: url)
        self.init(csv)
    }
    
    private static func parse(_ csv: CSV) -> Source {
        let languages = self.parseLanguages(csv)
        var source = self.generateEmptySource(languages)
        
        guard let columnKey = csv.header.first else {return source}
        
        for row in csv.namedRows {
            for lang in languages {
                guard let key = row[columnKey] else {continue}
                let value = row[lang]
                source[lang]?[key] = value
            }
        }

        return source
    }
    
    private typealias LanguageRef = ArraySlice<Language>
    private static func parseLanguages(_ csv: CSV) -> LanguageRef {
        csv.header.dropFirst()
    }
    
    private static func generateEmptySource(_ languages: LanguageRef) -> Source {
        var source: Source = [:]
        return languages.reduce(source) { _, nextLang in
            source[nextLang] = [:]
            return source
        }
    }
}
