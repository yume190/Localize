//
//  IOSGenerator.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation
import Path

/// zh-Hant.lproj/Localizable.strings
public struct IOSGenerator: LanguageGenerator, CodeGenerator {
    private let generator: CustomGenerator
    public init(_ path: String = ".") {
        let config = CustomGeneratorConfig(
            file: "{language}.lproj/Localizable.strings",
            separator: "\n",
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
