//
//  AndroidGenerator.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation

/// values-zh-rTW/strings.xml
struct AndroidGenerator: LanguageGenerator {
    
    private let outputPath: URL
    init(_ outputPath: String = ".") {
        self.outputPath = URL(fileURLWithPath: outputPath)
    }
    
    func generate(provider: LanguageProvider) throws {
        try provider.sources.forEach(self.generating)
    }
    
    /// values-zh-rTW
    private func generating(_ lang: Language, _ mapping: Mapping) throws {
        /// values-zh-rTW
        let folder = outputPath.appendingPathComponent("values-\(lang)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        
        /// values-zh-rTW/strings.xml
        let targetFile = folder.appendingPathComponent("strings.xml")
        try self.output(mapping).write(to: targetFile, atomically: true, encoding: .utf8)
    }
    
    // <resources>
    //     <string name="alert">栏位不可为空白!!</string>
    // </resources>
    private func output(_ mapping: Mapping) -> String {
        let content = mapping.map { key, value in
            return """
                <string name="\(key)">\(value)</string>
            """
        }.joined(separator: "\n")
        
        return """
        <resources>
        \(content)
        </resources>
        """
    }
}
