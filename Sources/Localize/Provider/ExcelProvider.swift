//
//  ExcelProvider.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import CoreXLSX

enum ExcelError: Error {
    case notFound(path: String)
    case cantGetContent
    case outOfIndex
}

public struct ExcelProvider: LanguageProvider {
    public let sources: Source
    init(_ filePath: String, workSheetIndex: Int = 0) throws {
        guard let file = XLSXFile(filepath: filePath) else {
            throw ExcelError.notFound(path: filePath)
        }
        guard let sharedStrings = try file.parseSharedStrings() else {
            throw ExcelError.cantGetContent
        }
        guard let wbk = try file.parseWorkbooks().first else {
            throw ExcelError.notFound(path: filePath)
        }
        
        let workSheets = try file.parseWorksheetPathsAndNames(workbook: wbk)
        guard workSheets.count > workSheetIndex else {
            throw ExcelError.outOfIndex
        }
        let worksheet = try file.parseWorksheet(at: workSheets[workSheetIndex].path)
        self.sources = ExcelProvider.parse(worksheet, sharedStrings)
    }
    
    private static func parse(_ workSheet: Worksheet, _ sharedStrings: SharedStrings) -> Source {
        let languages = self.parseLanguages(workSheet, sharedStrings)
        var source = self.generateEmptySource(languages.map(\.lang))
        
        let columnKey = ColumnReference("A")!
        for keyCell in workSheet.cells(atColumns: [columnKey]) {
            guard keyCell.reference.row != 0 else {continue}
            guard let key = keyCell.stringValue(sharedStrings) else {continue}
            for language in languages {
                let valueCell = workSheet.cells(atColumns: [language.column.column], rows: [keyCell.reference.row]).first
//                guard let value = valueCell?.stringValue(sharedStrings) else {continue}
//                source[language.lang]?[key] = value
                
                source[language.lang]?[key] = valueCell?.stringValue(sharedStrings)
            }
        }
        return source
    }
    
    private typealias LanguageRef = [(lang: Language, column: CellReference)]
    private static func parseLanguages(_ workSheet: Worksheet, _ sharedStrings: SharedStrings) -> LanguageRef {
        let langCells = workSheet.cells(atRows: 1...1)
        return langCells.compactMap { cell in
            guard let lang = cell.stringValue(sharedStrings) else {return nil}
            let column = cell.reference
            guard column.column.value != "A" else {return nil}
            return (lang, column)
        }
    }
    
    private static func generateEmptySource(_ languages: [Language]) -> Source {
        var source: Source = [:]
        return languages.reduce(source) { _, nextLang in
            source[nextLang] = [:]
            return source
        }
    }
}
