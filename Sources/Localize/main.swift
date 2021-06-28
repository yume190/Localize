import LocalizeFramework
import ArgumentParser
import Foundation

// ExpressibleByArgument -> @Option
fileprivate enum InputType: String, ExpressibleByArgument, Codable {
    case csv, excel, ios
}

// EnumerableFlag -> @Flag
fileprivate enum OutputType: String, EnumerableFlag, Codable {
    case ios, ios_code, android, custom
    var option: Options {
        switch self {
        case .ios: return .ios
        case .ios_code: return .ios_code
        case .android: return .android
        case .custom: return .custom
        }
    }
    
    fileprivate struct Options: OptionSet {
        let rawValue: Int

        static let ios = Options(rawValue: 1 << 0)
        static let ios_code = Options(rawValue: 1 << 1)
        static let android = Options(rawValue: 1 << 2)
        static let custom = Options(rawValue: 1 << 3)
    }
}

extension Array where Element == OutputType {
    var options: OutputType.Options {
        return self.reduce([]) { origin, next in
            origin.union(next.option)
        }
    }
}

fileprivate struct Configure: Codable {
    let inputType: InputType
    let input: String
    
    let outputType: OutputType
    let output: String
    
    let customGenerator: String?
}

fileprivate struct LocalizeCommand: ParsableCommand {
    @Option(name: [.customLong("inputType", withSingleDash: false), .customLong("it", withSingleDash: false)], help: "Input Type: <excel|csv|ios>.")
    var inputType: InputType = .csv
    
    @Option(name: [.customLong("input", withSingleDash: false), .customShort("i")], help: "Input file path.")
    var input: String

//    @Option(name: [.customLong("outputType", withSingleDash: false), .customLong("ot", withSingleDash: false)], help: "Type: <ios|ios_code|android|custom>.")
    @Flag(help: "Output Type: <ios|ios_code|android|custom>.")
    var outputType: [OutputType] = [.ios]

    @Option(name: [.customLong("output", withSingleDash: false), .customShort("o")], help: "Output file.")
    var output: String = "."
    
    @Option(name: [.customLong("custom_generator", withSingleDash: false)], help: "If output type is `custom`, you need to provide a custom generator yml path.")
    var customGenerator: String?

    
    func run() throws {
        let provider = try self.provider()
        let generators = try self.generators()
        try generators.forEach { generator in
            try generator.generate(provider: provider)
        }
    }
    
    private func provider() throws -> LanguageProvider {
        switch self.inputType {
        case .csv:
            return try CSVProvider(input)
        case .excel:
            return try ExcelProvider(input)
        case .ios:
            return IOSProvider(input)
        }
    }

    private func generators() throws -> [LanguageGenerator] {
        let options = self.outputType.options
        var result: [LanguageGenerator] = []
        
        if options.contains(.ios) { result.append(IOSGenerator2(output)) }
        if options.contains(.ios_code) { result.append(IOSCodeGenerator(output)) }
        if options.contains(.android) { result.append(AndroidGenerator2(output)) }
        if options.contains(.custom) {
            try result.append(CustomGenerator(output, customGenerator))
        }
        return result
    }
}

LocalizeCommand.main()
