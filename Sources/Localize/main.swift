import ArgumentParser

enum FileType: String, ExpressibleByArgument {
    case csv, excel, ios
}

enum OutputType: String, ExpressibleByArgument {
    case ios, android
}

struct LocalizeCommand: ParsableCommand {
    @Option(name: [.customLong("inputType", withSingleDash: false), .customLong("it", withSingleDash: false)], help: "Type: <excel|csv|ios>.")
    var inputType: FileType = .csv
    
    @Option(name: [.customLong("input", withSingleDash: false), .customShort("i")], help: "Input file path.")
    var input: String

    @Option(name: [.customLong("outputType", withSingleDash: false), .customLong("ot", withSingleDash: false)], help: "Type: <ios|android>.")
    var outputType: OutputType = .ios

    @Option(name: [.customLong("output", withSingleDash: false), .customShort("o")], help: "Output file.")
    var output: String = "."

    
    func run() throws {
        let provider = try self.provider()
        let generator = self.generator()
        try generator.generate(provider: provider)
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

    private func generator() -> LanguageGenerator {
        switch outputType {
        case .ios:
            return IOSGenerator(output)
        case .android:
            return AndroidGenerator(output)
        }
    }
}

LocalizeCommand.main()
