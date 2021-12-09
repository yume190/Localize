//
//  IOSCodeGenerator.swift
//  
//
//  Created by Yume on 2021/6/24.
//

import Foundation
import Path

/// output/Localize.swift
public struct IOSCodeGenerator: LanguageGenerator {
    private let path: Path
    
    public init(_ path: String = ".") {
        self.path = Path(path) ?? Path.cwd/path
    }
    
    public func generate(provider: LanguageProvider) throws {
        guard let en = provider.sources["en"] else {return}
        
        let targetFile = path/"Localize.swift"
        try targetFile.parent.mkdir(.p)
        
        let code = extractCode(mapping: en)
        let result = output(code)
        try result.write(to: targetFile, atomically: true, encoding: .utf8)
    }
    
    private func output(_ code: String) -> String {
        return """
        public enum L10n {
        \(code)
        }
        
        extension L10n {
            private static func tr(table: String = "Localizable", key: String, value: String? = nil) -> String {
                return BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
            }
        
            private static func trArgs(table: String = "Localizable", key: String, _ args: CVarArg...) -> String {
                // let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
                let format = self.tr(table: table, key: key)
                    .replacingOccurrences(of: "%s", with: "%@")
                return String(format: format, locale: Locale.current, arguments: args)
            }
        }

        // swiftlint:disable convenience_type
        private final class BundleToken {
            static let bundle: Bundle = {
                #if SWIFT_PACKAGE
                return Bundle.module
                #else
                return Bundle(for: BundleToken.self)
                #endif
            }()
        }
        // swiftlint:enable convenience_type
        """
    }
    
    private func extractCode(mapping: Mapping) -> String {
        mapping.sorted(by: { lhs, rhs in
            return lhs.key < rhs.key
        }).map { key, value in
            let count = value.count(component: "%s")
            guard count == 0 else {
                let range = (0..<count)
                let args = range.map {"_ p\($0): String"}.joined(separator: ", ")
                let params = range.map {"p\($0)"}.joined(separator: ", ")
                return """
                    /// \(value)
                    public static func \(key)(\(args)) -> String {
                        return L10n.trArgs(key: "\(key)", \(params))
                    }
                """
            }
            
            return """
                /// \(value)
                public static let \(key): String = L10n.tr(key: "\(key)")
            """
        }.joined(separator: "\n")
    }
}


fileprivate extension String {
    func count(component: String) -> Int {
        return max(self.components(separatedBy: component).count - 1, 0)
    }
}
