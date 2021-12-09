//
//  Protocols.swift
//  
//
//  Created by Yume on 2021/6/18.
//

import Foundation

public typealias Language = String
public typealias Mapping = [String: String]
public typealias Source = [Language: Mapping]
public protocol LanguageProvider {
    var sources: Source {get}
}

public protocol LanguageGenerator {
    func generate(provider: LanguageProvider) throws
}

internal protocol CodeGenerator {
    func generateCode(_ mapping: Mapping) -> String
}
