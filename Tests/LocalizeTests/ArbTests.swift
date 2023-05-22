//
//  ArbTests.swift
//  
//
//  Created by Yume on 2023/5/11.
//

import XCTest
@testable import LocalizeFramework

final class ArbTests: XCTestCase {
    func testExtract1() {
        let transfrom = ArbGenerator.extract("{a: Int}")
        XCTAssertEqual("{a}", transfrom?.transformedValue)
        XCTAssertEqual([
            "a": "Int"
        ], transfrom?.types)
    }
    
    func testExtract2() {
        let transfrom = ArbGenerator.extract("{a:    Int}")
        XCTAssertEqual("{a}", transfrom?.transformedValue)
        XCTAssertEqual([
            "a": "Int"
        ], transfrom?.types)
    }
    
    func testExtract3() {
        let transfrom = ArbGenerator.extract("{a: Int} b {c: Float}")
        XCTAssertEqual("{a} b {c}", transfrom?.transformedValue)
        XCTAssertEqual([
            "a": "Int",
            "c": "Float"
        ], transfrom?.types)
    }
        
    
    func testGenCode1() {
        let gen = ArbGenerator()
        let txt = gen.generateCode([
            "a": "{a: Int} b {c: Float}",
        ])
        XCTAssertEqual(txt, """
        {
          "a": "{a} b {c}",
          "@a": {
            "placeholders": {
              "a": {
                "type": "Int"
              },
              "c": {
                "type": "Float"
              }
            }
          }
        }
        """)
    }
    
    func testGenCode2() {
        let gen = ArbGenerator()
        let txt = gen.generateCode([
            "a": "{a: Int} b {c: Float}",
            "b": "{a:  String} b {c: Float} {c: Float}",
        ])
        XCTAssertEqual(txt, """
        {
          "a": "{a} b {c}",
          "@a": {
            "placeholders": {
              "a": {
                "type": "Int"
              },
              "c": {
                "type": "Float"
              }
            }
          },
          "b": "{a} b {c} {c}",
          "@b": {
            "placeholders": {
              "a": {
                "type": "String"
              },
              "c": {
                "type": "Float"
              }
            }
          }
        }
        """)
    }
}
