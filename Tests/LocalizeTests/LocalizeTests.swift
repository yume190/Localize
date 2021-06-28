import XCTest
@testable import LocalizeFramework
import SwiftCSV

final class LocalizeTests: XCTestCase {
    private final let sourceFile: URL = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Resource")
    
    private final func resource(file: String) -> String {
        return sourceFile.appendingPathComponent(file).path
    }
    
    // MARK: Resource
    
    /// "a","'"
    /// "b","\'"
    /// "c","\\"
    /// "d","\t"
    /// "e",""""
    /// "f","\"""
    /// "g","&"
    /// "h","<"
    /// "i",">"
    let origin: Mapping = [
        "a": "'",
        "b": "\'",
        "c": "\\",
        "d": "\t",
        "e": "\"",
        "f": "\\\"",
        "g": "&",
        "h": "<",
        "i": ">",
    ]
    
    /// "a","'"
    /// "b","\'"
    /// "c","\\"
    /// "d","\t"
    /// "e",""""
    /// "f","\"""
    /// "g","&"
    /// "h","<"
    /// "i",">"
    let target: Mapping = [
        "a": "\'",
        "b": "\\\'",
        "c": "\\\\",
        "d": "\\t",
        "e": "\"",
        "f": "\\\"",
        "g": "&",
        "h": "<",
        "i": ">",
    ]
    
//    func te2stCSV() throws {
//        let resource = self.resource(file: "data.csv")
//        let provider = try CSVProvider(resource)
//        let generatedCode = IOSGenerator().generateCode(provider.sources["en"]!)
////        print(generatedCode)
//
//        let code = """
//        "a" = "'";
//        "b" = "\'";
//        "c" = "\\";
//        "d" = "\t";
//        "e" = "\"";
//        "f" = "\\\"";
//        """
//        XCTAssertEqual(generatedCode, code)
//    }
    
    // MARK: Provider
    func testCSVProvider() throws {
        let resource = self.resource(file: "data.csv")
        let provider = try CSVProvider(resource)
        let extract = provider.sources["en"]!
        XCTAssertEqual(
            extract.sorted(by: self.sort(l:r:)).map(\.value),
            target.sorted(by: self.sort(l:r:)).map(\.value)
        )
    }
    
    func testXLSXProvider() throws {
        let resource = self.resource(file: "data.xlsx")
        let provider = try ExcelProvider(resource)
        let extract = provider.sources["en"]!
        XCTAssertEqual(
            extract.sorted(by: self.sort(l:r:)).map(\.value),
            target.sorted(by: self.sort(l:r:)).map(\.value)
        )
    }
    
    func todoTestAndroidGenerator() throws {
        let generatedCode = AndroidGenerator2().generateCode(target)
        
//        <string name="{key}">{value}</string>
        let code = """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
        "a" = "'";
        "b" = "\'";
        "c" = "\\";
        "d" = "\t";
        "e" = "\"";
        "f" = "\\\"";
        </resources>
        """
    }
    
    /// user -> swift
    /// '    -> \'
    /// \'   -> \\\'
    /// \\   -> \\\\
    /// \t   -> \\t
    /// "    -> \"
    /// \"   -> \\\"
    func todoTestIOSGenerator() throws {
        let resource = self.resource(file: "data.xlsx")
        let provider = try ExcelProvider(resource)
        let generatedCode = IOSGenerator2().generateCode(provider.sources["en"]!)
        print(generatedCode)
//        "
//        "a" = "'";
//        "b" = "\\'";
//        "c" = "\\\\";
//        "d" = "\\t";
//        "e" = "\"";
//        "f" = "\\\"";
//        "
//        ""a" = "'";
//        "b" = "'";
//        "c" = "\";
//        "d" = "    ";
//        "e" = """;
//        "f" = "\"";")
        
        // \"d\" = \"\\t\";
        let code = """
        
        "a" = "'";
        "b" = "\'";
        "c" = "\\";
        "d" = "\t";
        "e" = "\"";
        "f" = "\\\"";
        
        """
        XCTAssertEqual(generatedCode, code)
    }

    /// user -> swift
    /// '    -> \'
    /// \'   -> \\\'
    /// \\   -> \\\\
    /// \t   -> \\t
    /// "    -> \"
    /// \"   -> \\\"
    func testTransform() throws {
        XCTAssertEqual("'", "\'")
        
        XCTAssertEqual(transform("""
        '
        """), "\'")
        XCTAssertEqual(transform("""
        \'
        """), "\'")
        XCTAssertEqual(transform("\\"), "\\\\")
        XCTAssertEqual(transform("\t"), "\t")
        XCTAssertEqual(transform("""
        "
        """), "\\\"")
        XCTAssertEqual(transform("""
        \"
        """), "\\\"")
    }
    func testTransformA() throws {
        XCTAssertEqual(transformA("&"), "&amp;")
        XCTAssertEqual(transformA("<"), "&lt;")
        XCTAssertEqual(transformA(">"), "&gt;")
    }
    
    func transform(_ str: String) -> String {
        return str
            .replacingOccurrences(of: "\\", with: "\\\\")
//            .replacingOccurrences(of: "'", with: "\\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
        
    /// &amp; → & (ampersand, U+0026)
    /// &lt; → < (less-than sign, U+003C)
    /// &gt; → > (greater-than sign, U+003E)
    func transformA(_ str: String) -> String {
        return str
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

//String.StringInterpolation

extension LocalizeTests {
    typealias MappingElement = (key: String, value: String)
    func sort(l: MappingElement, r: MappingElement) -> Bool {
        return l.key < r.key
    }
}
