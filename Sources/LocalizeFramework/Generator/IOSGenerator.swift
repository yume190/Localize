//
//  IOSGenerator.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation
import Path

/// zh-Hant.lproj/Localizable.strings
//public struct IOSGenerator: LanguageGenerator, CodeGenerator {
//    private let path: Path
//    
//    public init(_ path: String = ".") {
//        self.path = Path(path) ?? Path.cwd/path
//    }
//    
//    public func generate(provider: LanguageProvider) throws {
//        try provider.sources.forEach(self.generating)
//    }
//    
//    private func generating(_ lang: Language, _ mapping: Mapping) throws {
//        let targetFile = self.path/"\(lang).lproj/Localizable.strings"
//        
//        // mkdir -p
//        try targetFile.parent.mkdir(.p)
//
//        try self.generateCode(mapping).write(to: targetFile, atomically: true, encoding: .utf8)
//    }
//    
//    func generateCode(_ mapping: Mapping) -> String {
//        return mapping.sorted(by: { lhs, rhs in
//            return lhs.key < rhs.key
//        }).map { key, value in
//            return """
//            "\(key)" = "\(value)";
//            """
//        }.joined(separator: "\n")
//    }
//}

public struct IOSGenerator2: LanguageGenerator, CodeGenerator {
    private let generator: CustomGenerator
    public init(_ path: String = ".") {
        let config = CustomGeneratorConfig(
            file: "{language}.lproj/Localizable.strings",
            codePrefix: nil,
            codeFormat: """
            "{key}" = "{value}";
            """,
            codeSuffix: nil,
            replaces: .ios
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
