//
//  ReplaceTests.swift
//  
//
//  Created by Yume on 2021/6/28.
//

import XCTest
@testable import LocalizeFramework

final class ReplaceTests: XCTestCase {
    // MARK: Replace
    
    /// user -> swift -> write
    /// &    -> &     -> &
    /// &    -> &     -> &amp;
    func testReplaceAnd() throws {
        XCTAssertEqual(replace("&", .ios),     "&")
        XCTAssertEqual(replace("&", .android), "&amp;")
    }
    
    /// user -> swift -> write
    /// >    -> >     -> >
    /// >    -> >     -> &gt;
    func testReplaceGreater() throws {
        XCTAssertEqual(replace(">", .ios),     ">")
        XCTAssertEqual(replace(">", .android), "&gt;")
    }
    
    /// user -> swift -> write
    /// <    -> <     -> <
    /// <    -> <     -> &lt;
    func testReplaceLesser() throws {
        XCTAssertEqual(replace("<", .ios),     "<")
        XCTAssertEqual(replace("<", .android), "&lt;")
    }
    
    /// user -> swift -> write
    /// '    -> \'    -> \\\'
    func testReplaceCaseA() throws {
        XCTAssertEqual(replace("\'", .ios),     "\\\'")
        XCTAssertEqual(replace("\'", .android), "\\\'")
    }
    
    // \'
    /// user -> swift -> write
    /// \'   -> \\\'  -> \\\\\\\'
    func testReplaceCaseB() throws {
        XCTAssertEqual(replace("\\\'", .ios),     "\\\\\\\'")
        XCTAssertEqual(replace("\\\'", .android), "\\\\\\\'")
    }
    
    /// user -> swift -> write
    /// \\   -> \\\\  -> \\\\\\\\
    func testReplaceCaseC() throws {
        XCTAssertEqual(replace("\\\\", .ios),     "\\\\\\\\")
        XCTAssertEqual(replace("\\\\", .android), "\\\\\\\\")
    }
    
    /// user -> swift -> write
    /// \t   -> \\t  -> \t
    func testReplaceCaseD() throws {
        XCTAssertEqual(replace("\\t", .ios),     "\\t")
        XCTAssertEqual(replace("\\t", .android), "\\t")
    }
    
    /// user -> swift -> write
    /// "    -> \"    -> \\\"
    func testReplaceCaseE() throws {
        XCTAssertEqual(replace("\"", .ios),     "\\\"")
        XCTAssertEqual(replace("\"", .android), "\\\"")
    }
    
    /// user -> swift -> write
    /// \"   -> \\\"  -> \\\\\\\"
    func testReplaceCaseF() throws {
        XCTAssertEqual(replace("\\\"", .ios),     "\\\\\\\"")
        XCTAssertEqual(replace("\\\"", .android), "\\\\\\\"")
    }
    
    // MARK: Escape
    func testReplaceEscapeTab() throws {
        XCTAssertEqual(replace("\\t", .ios),     "\\t")
        XCTAssertEqual(replace("\\t", .android), "\\t")
        XCTAssertEqual(replace("\t", .ios),     "\\t")
        XCTAssertEqual(replace("\t", .android), "\\t")
    }
    
    func testReplaceEscapeNewLine() throws {
        XCTAssertEqual(replace("\\n", .ios),     "\\n")
        XCTAssertEqual(replace("\\n", .android), "\\n")
        XCTAssertEqual(replace("\n", .ios),     "\\n")
        XCTAssertEqual(replace("\n", .android), "\\n")
    }
    
    func testReplaceEscapeCarriageReturn() throws {
        XCTAssertEqual(replace("\\r", .ios),     "\\r")
        XCTAssertEqual(replace("\\r", .android), "\\r")
        XCTAssertEqual(replace("\r", .ios),     "\\r")
        XCTAssertEqual(replace("\r", .android), "\\r")
    }
    
    func replace(_ str: String, _ replaces: [CustomGeneratorConfig.Replace]) -> String {
        return replaces.replacing(str)
    }
}
