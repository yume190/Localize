//
//  CustomGenerator.swift
//  
//
//  Created by Yume on 2021/6/24.
//

import Foundation
import Path
import Yams

typealias CodeTransform = (_ key: String, _ value: String) -> String
struct CustomGeneratorConfig: Decodable {
    /// {language}
    let file: String
    
    let separator: String
    
    let codePrefix: String?
    /// {key}, {value}
    let codeFormat: String
    let codeTransform: CodeTransform?
    
    let codeSuffix: String?
    
    let replaces: [Replace]?
    
    
    init(file: String, separator: String, codePrefix: String?, codeFormat: String, codeSuffix: String?, replaces: [Replace]?) {
        self.file = file
        self.separator = separator
        self.codePrefix = codePrefix
        
        self.codeFormat = codeFormat
        self.codeTransform = nil
        
        self.codeSuffix = codeSuffix
        self.replaces = replaces
    }
    
    init(file: String, separator: String, codePrefix: String?, codeTransform: @escaping CodeTransform, codeSuffix: String?, replaces: [Replace]?) {
        self.file = file
        self.separator = separator
        self.codePrefix = codePrefix
        
        self.codeFormat = ""
        self.codeTransform = codeTransform
        
        self.codeSuffix = codeSuffix
        self.replaces = replaces
    }
    
    
    
    enum CodingKeys: CodingKey {
        case file
        case separator
        case codePrefix
        case codeFormat
        case codeSuffix
        case replaces
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CustomGeneratorConfig.CodingKeys> = try decoder.container(keyedBy: CustomGeneratorConfig.CodingKeys.self)
        self.file = try container.decode(String.self, forKey: CustomGeneratorConfig.CodingKeys.file)
        self.separator = try container.decode(String.self, forKey: CustomGeneratorConfig.CodingKeys.separator)
        self.codePrefix = try container.decode(String?.self, forKey: CustomGeneratorConfig.CodingKeys.codePrefix)
        self.codeFormat = try container.decode(String.self, forKey: CustomGeneratorConfig.CodingKeys.codeFormat)
        self.codeTransform = nil
        self.codeSuffix = try container.decode(String?.self, forKey: CustomGeneratorConfig.CodingKeys.codeSuffix)
        self.replaces = try container.decode([Replace]?.self, forKey: CustomGeneratorConfig.CodingKeys.replaces)
    }
    
    
    struct Replace: Decodable {
        let from: String
        let to: String
    }
}

extension Array where Element == CustomGeneratorConfig.Replace {
    static let empty: [Element] = []
    /// escaping character
    static let common: [Element] = [
        .init(from: "\\t", to: "\t"),
        .init(from: "\\n", to: "\n"),
        .init(from: "\\r", to: "\r"),
        
        /// \ -> \\
        .init(from: "\\", to: "\\\\"),
        /// ' -> \'
        .init(from: "\'", to: "\\\'"),
        /// " -> \"
        .init(from: "\"", to: "\\\""),
        
        .init(from: "\t", to: "\\t"),
        .init(from: "\n", to: "\\n"),
        .init(from: "\r", to: "\\r"),
    ]
    
    /// https://www.advancedinstaller.com/user-guide/xml-escaped-chars.html
    static let xml: [Element] = [
        /// &amp; → & (ampersand, U+0026)
        .init(from: "&", to: "&amp;"),
        /// &lt; → < (less-than sign, U+003C)
        .init(from: "<", to: "&lt;"),
        /// &gt; → > (greater-than sign, U+003E)
        .init(from: ">", to: "&gt;"),
        
        /// &quot; -> "
        /// &apos; -> '
    ]
    
    static let ios: [Element] = .common
    static let android: [Element] = .common + .xml
    
    func replacing(_ value: String) -> String {
        self.reduce(value) { sum, next in
            return sum.replacingOccurrences(of: next.from, with: next.to)
        }
    }
}

public enum CustomGeneratorError: Error {
    case ymlNotFound
}

public struct CustomGenerator: LanguageGenerator, CodeGenerator {
    private let path: Path
    private let config: CustomGeneratorConfig
    
    public init(_ path: String = ".", _ configYMLPath: String?) throws {
        guard let yml = configYMLPath else { throw CustomGeneratorError.ymlNotFound }
        let ymlPath = Path(yml) ?? Path.cwd/yml
        let data = try Data(contentsOf: ymlPath)
        let config = try YAMLDecoder().decode(CustomGeneratorConfig.self, from: data)
        self.init(path, config)
    }
    
    init(_ path: String = ".", _ config: CustomGeneratorConfig) {
        self.path = Path(path) ?? Path.cwd/path
        self.config = config
    }
    
    public func generate(provider: LanguageProvider) throws {
        try provider.sources.forEach(self.generating)
    }
    
    private func generating(_ lang: Language, _ mapping: Mapping) throws {
        let targetFilePath = config.file.replacingOccurrences(of: "{language}", with: "\(lang)")
        let targetFile = self.path/targetFilePath
        
        // mkdir -p
        try targetFile.parent.mkdir(.p)

        try self.generateCode(mapping).write(to: targetFile, atomically: true, encoding: .utf8)
    }
    
    func generateCode(_ mapping: Mapping) -> String {
        let content = mapping.sorted(by: { lhs, rhs in
            return lhs.key < rhs.key
        }).map { key, value in
            let newValue = (self.config.replaces ?? []).replacing(value)
            if let transform = config.codeTransform {
                return transform(key, newValue)
            } else {
                return config.codeFormat
                    .replacingOccurrences(of: "{key}", with: key)
                    .replacingOccurrences(of: "{value}", with: newValue)
            }

        }.joined(separator: config.separator)
        
        return """
        \(self.config.codePrefix ?? "")
        \(content)
        \(self.config.codeSuffix ?? "")
        """
    }
}
