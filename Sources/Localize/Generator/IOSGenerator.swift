//
//  IOSGenerator.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation

/// zh-Hant.lproj/Localizable.strings
struct IOSGenerator: LanguageGenerator {
    private let outputPath: URL
    
    init(_ outputPath: String = ".") {
        self.outputPath = URL(fileURLWithPath: outputPath)
    }
    
    func generate(provider: LanguageProvider) throws {
        try provider.sources.forEach(self.generating)
    }
    
    private func generating(_ lang: Language, _ mapping: Mapping) throws {
        /// zh-Hant.lproj
        let folder = outputPath.appendingPathComponent("\(lang).lproj")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        
        /// zh-Hant.lproj/Localizable.strings
        let targetFile = folder.appendingPathComponent("Localizable.strings")
        try self.output(mapping).write(to: targetFile, atomically: true, encoding: .utf8)
    }
    
    private func output(_ mapping: Mapping) -> String {
        return mapping.map { key, value in
            return """
            "\(key)" = "\(value)";
            """
        }.joined(separator: "\n")
    }
}
