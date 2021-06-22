import ArgumentParser

enum FileType: String, EnumerableFlag {
    case csv, excel, ios
}

enum OutputType: String, EnumerableFlag {
    case ios, android
}

struct LocalizeCommand: ParsableCommand {
    @Flag
    var fileType: FileType = .csv
    
    @Option(name: [.customLong("input", withSingleDash: false), .short], help: "input file")
    var inputPath: String
    
    @Flag
    var outputType: OutputType = .ios
    
    @Option(name: [.customLong("output", withSingleDash: false), .short], help: "output file")
    var outputPath: String = "."
    
    func run() throws {
        let provider = try self.provider()
        let generator = self.generator()
        try generator.generate(provider: provider)
    }
    
    private func provider() throws -> LanguageProvider {
        switch self.fileType {
        case .csv:
            return try CSVProvider(inputPath)
        case .excel:
            return try ExcelProvider(inputPath)
        case .ios:
            return IOSProvider(inputPath)
        }
    }
    
    private func generator() -> LanguageGenerator {
        switch outputType {
        case .ios:
            return IOSGenerator(outputPath)
        case .android:
            return AndroidGenerator(outputPath)
        }
    }
}

LocalizeCommand.main()
