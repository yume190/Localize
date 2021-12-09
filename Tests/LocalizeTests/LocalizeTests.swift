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
    
    // MARK: Generator
    
    /// "a","'"
    /// "b","\'"
    /// "c","\\"
    /// "d","\t"
    /// "e",""""
    /// "f","\"""
    /// "g","&"
    /// "h","<"
    /// "i",">"
    func testAndroidGenerator() throws {
        let generatedCode = AndroidGenerator().generateCode(target)
        let code = """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
            <string name="a">\\\'</string>
            <string name="b">\\\\\\\'</string>
            <string name="c">\\\\\\\\</string>
            <string name="d">\\t</string>
            <string name="e">\\\"</string>
            <string name="f">\\\\\\\"</string>
            <string name="g">&amp;</string>
            <string name="h">&lt;</string>
            <string name="i">&gt;</string>
        </resources>
        """
        XCTAssertEqual(generatedCode, code)
    }
    
    /// "a","'"
    /// "b","\'"
    /// "c","\\"
    /// "d","\t"
    /// "e",""""
    /// "f","\"""
    /// "g","&"
    /// "h","<"
    /// "i",">"
    func testIOSGenerator() throws {
        let generatedCode = IOSGenerator().generateCode(target)
        let code = """
        
        "a" = "\\\'";
        "b" = "\\\\\\\'";
        "c" = "\\\\\\\\";
        "d" = "\\t";
        "e" = "\\\"";
        "f" = "\\\\\\\"";
        "g" = "&";
        "h" = "<";
        "i" = ">";
        
        """
        XCTAssertEqual(generatedCode, code)
    }
}

extension LocalizeTests {
    typealias MappingElement = (key: String, value: String)
    func sort(l: MappingElement, r: MappingElement) -> Bool {
        return l.key < r.key
    }
}
