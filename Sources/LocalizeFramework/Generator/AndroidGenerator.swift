//
//  AndroidGenerator.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation

/// generate values-lang/strings.xml
public struct AndroidGenerator: LanguageGenerator, CodeGenerator {
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
