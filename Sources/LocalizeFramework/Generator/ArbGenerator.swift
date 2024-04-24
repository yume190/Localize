//
//  ArbGenerator.swift
//  
//
//  Created by Yume on 2023/5/11.
//

import Foundation
import Path

/// https://flutter.cn/docs/development/accessibility-and-localization/internationalization
/// [arb](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)

/// lib/l10n/app_en.arb
public struct ArbGenerator: LanguageGenerator, CodeGenerator {
        private let generator: CustomGenerator
    let path: Path
    public init(_ path: String = ".") {
        self.path = Path(path) ?? Path.cwd/path
        
        let config = CustomGeneratorConfig(
            file: "lib/l10n/app_{language}.arb",
            separator: ",\n",
            codePrefix: "{",
            codeTransform: Self.transform,
            codeSuffix: "}",
            replaces: .arb
        )
        self.generator = CustomGenerator(path, config)
    }
    
    public func generate(provider: LanguageProvider) throws {
        try self.generator.generate(provider: provider)
    }
    
    func generateCode(_ mapping: Mapping) -> String {
        return self.generator.generateCode(mapping)
    }
    
    private static func transform(_ key: String, _ value: String) -> String {
        let newKey = key.lowercased()
        guard let transform = Self.extract(value) else {
            return """
            "\(newKey)": "\(value)",
            """.indent(1, "  ")
        }
        
        guard !transform.placeholders.isEmpty else {
            return """
            "\(newKey)": "\(transform.transformedValue)"
            """.indent(1, "  ")
        }
        
        return """
        "\(newKey)": "\(transform.transformedValue)",
        "@\(newKey)": {
          "placeholders": {
        \(transform.placeholders.indent(2, "  "))
          }
        }
        """.indent(1, "  ")
    }
    
//    private func trans(_ mapping: Mapping) -> String {
//        return mapping
//            .map(Self.transform)
//            .sorted()
//            .joined(separator: ",\n")
//    }
}

extension ArbGenerator {
    struct Transform {
        let types: [String: String]
        let transformedValue: String
        
        var placeholders: String {
            types.map { name, _type in
                """
                "\(name)": {
                  "type": "\(_type)"
                }
                """
            }.sorted().joined(separator: ",\n")
        }
    }
    
    static func extract(_ string: String) -> Transform? {
        var types: [String: String] = [:]
        var replaces: [(range: Range<String.Index>, text: String)] = []
        
        let pattern = #"\{(\w+):\s*(\w+)\}"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            for match in matches {
                if let range1 = Range(match.range(at: 1), in: string),
                   let range2 = Range(match.range(at: 2), in: string) {
                    let key = String(string[range1])
                    let value = String(string[range2])
                    types[key] = value
                    
                    let range = Range<String.Index>(uncheckedBounds: (lower: range1.lowerBound, upper: range2.upperBound))
                    
                    replaces.append((range, key))
                }
            }
        } catch {
            print("regex error：\(error)")
            return nil
        }
        
        var newString = string
        replaces.reversed().forEach { range, value in
            newString.replaceSubrange(range, with: value)
        }
        
        return .init(types: types, transformedValue: newString)
    }
}
