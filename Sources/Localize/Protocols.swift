//
//  File.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation

//public enum Language {
//    case english
//    case chinese
//    case custom(language: String)
//}

public typealias Language = String
public typealias Mapping = [String: String]
public typealias Source = [Language: Mapping]
public protocol LanguageProvider {
    var sources: Source {get}
}

public protocol LanguageGenerator {
    func generate(provider: LanguageProvider) throws
}
