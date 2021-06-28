//
//  AndroidGenerator.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation

/// values-zh-rTW/strings.xml
//public struct AndroidGenerator: LanguageGenerator, CodeGenerator {
//    
//    private let outputPath: URL
//    public init(_ outputPath: String = ".") {
//        self.outputPath = URL(fileURLWithPath: outputPath)
//    }
//    
//    public func generate(provider: LanguageProvider) throws {
//        try provider.sources.forEach(self.generating)
//    }
//    
//    /// values-zh-rTW
//    private func generating(_ lang: Language, _ mapping: Mapping) throws {
//        /// values-zh-rTW
//        let folder = outputPath.appendingPathComponent("values-\(lang)")
//        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
//        
//        /// values-zh-rTW/strings.xml
//        let targetFile = folder.appendingPathComponent("strings.xml")
//        try self.generateCode(mapping).write(to: targetFile, atomically: true, encoding: .utf8)
//    }
//    
//    // <resources>
//    //     <string name="alert">栏位不可为空白!!</string>
//    // </resources>
//    func generateCode(_ mapping: Mapping) -> String {
//        let content = mapping.sorted(by: { lhs, rhs in
//            return lhs.key < rhs.key
//        }).map { key, value in
//            return """
//                <string name="\(key)">\(value)</string>
//            """
//        }.joined(separator: "\n")
//        
//        return """
//        <?xml version="1.0" encoding="utf-8"?>
//        <resources>
//        \(content)
//        </resources>
//        """
//    }
//}

public struct AndroidGenerator2: LanguageGenerator, CodeGenerator {
    private let generator: CustomGenerator
    public init(_ path: String = ".") {
        let config = CustomGeneratorConfig(
            file: "values-{language}/strings.xml",
            codePrefix: """
            <?xml version="1.0" encoding="utf-8"?>
            <resources>
            """,
            codeFormat: """
                <string name="{key}">{value}</string>
            """,
            codeSuffix: "</resources>",
            replaces: .android
        )
        self.generator = CustomGenerator(path, config)
    }
    
    public func generate(provider: LanguageProvider) throws {
        try self.generator.generate(provider: provider)
    }
    
    func generateCode(_ mapping: Mapping) -> String {
        return self.generator.generateCode(mapping)
    }
}
