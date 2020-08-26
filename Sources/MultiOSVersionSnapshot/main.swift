import MultiOSVersionSnapshotCore
import Foundation
import Yams
import Commander
import SwiftCLI
import PathKit

final class MultiOSVersionSnapshot {

    func run(ymlPath: String) {
        let url = URL(fileURLWithPath: ymlPath)
        guard let entity: YmlEntity = parseYaml(for: url) else {
            print("MultiOSVersionSnapshot: ⚠️ Fail to parse yaml options. Check the path of 'MultiOSVersionSnapshot.yml' file in your project.")
            return
        }
        if entity.osVersions.isEmpty {
            print("MultiOSVersionSnapshot: osVersions is required in the yml file!")
            return
        }
        if entity.outputDirectory.isEmpty {
            print("MultiOSVersionSnapshot: outputDirectory is required in the yml file!")
            return
        }
        if entity.shouldGeneratePDF {
            execute(command: "wkhtmltopdf --version") { [unowned self] result in
                if !result {
                    print("Install wkhtmltopdf......")
                    self.execute(command: "brew cask install wkhtmltopdf")
                }
            }
        }
        let snapshotExecutableCommand = entity.snapshotExecutableCommand ?? "fastlane snapshot"

        let snapshotCommandParameter = createSnapshotParameter(entity: entity)

        entity.osVersions.forEach({ osVersion in
            let outputPath = (Path(entity.outputDirectory) + Path(osVersion)).absolute().description
            let snapshotCommand = snapshotExecutableCommand + " --ios_version \(osVersion)" + " --output_directory \(outputPath.addDoubleQuotes)" + snapshotCommandParameter
            print("Executing on \(osVersion)....................")
            print(snapshotCommand)
            execute(command: snapshotCommand) {
                if !$0 {
                    print("Failed to execute command..")
                    exit(1)
                }
                if entity.shouldGeneratePDF {
                    self.execute(command: "wkhtmltopdf --title Snapshot-ver\(osVersion) --enable-local-file-access \(outputPath)/screenshots.html \(outputPath)/\(entity.pdfTitlePrefix)-\(osVersion).pdf")
                }
            }
        })
        print("All tasks completed 🎉🎉🎉🎉🎉")
    }

    private func parseYaml<T>(for url: URL) -> T? where T: Decodable {
        let decoder = YAMLDecoder()
        guard let ymlString = try? String(contentsOf: url) else { return nil }
        return try? decoder.decode(from: ymlString)
    }

    private func createSnapshotParameter(entity: YmlEntity) -> String {
        return entity.snapshot.map({ (key, value) -> String? in
            if let stringValue = value as? String {
                return "--" + key + " " + stringValue.addDoubleQuotes
            } else if let _ = value as? Bool {
                return "--" + key
            } else if let intValue = value as? Int {
                return "--" + key + " " + String(intValue)
            } else if let stringArray = value as? [String] {
                return "--" + key + " "  + stringArray.map({ $0.addDoubleQuotes })
                    .reduce("", { (sum, value) -> String in
                        return sum + (sum.isEmpty ? "" : ",") + value
                    })
            } else {
                return nil
            }
        })
        .compactMap({ $0 })
        .reduce("") { (sum, parameter) -> String in
            sum + " " + parameter
        }
    }

    private func createSnapshotCommands(parameter: YmlEntity) -> [String] {
        let snapshotCommand = parameter.snapshotExecutableCommand ?? "fastlane snapshot"
        let snapshotParameter = (parameter.snapshot).map({ (key, value) -> String? in
            if let stringValue = value as? String {
                return "--" + key + " " + stringValue.addDoubleQuotes
            } else if let _ = value as? Bool {
                return "--" + key
            } else if let intValue = value as? Int {
                return "--" + key + " " + String(intValue)
            } else if let stringArray = value as? [String] {
                return "--" + key + " "  + stringArray.map({ $0.addDoubleQuotes })
                    .reduce("", { (sum, value) -> String in
                        return sum + (sum.isEmpty ? "" : ",") + value
                    })
            } else {
                return nil
            }
        })
        .compactMap({ $0 })
        .reduce("") { (sum, parameter) -> String in
            sum + " " + parameter
        }
        return parameter.osVersions.map({ osVersion -> String in
            let outputPath = (Path(parameter.outputDirectory) + Path(osVersion)).absolute().description.addDoubleQuotes
            return snapshotCommand + " " + "--ios_version \(osVersion)"  + " --output_directory \(outputPath)" + snapshotParameter
        })
    }

    private func execute(command: String, completion: ((Bool) -> Void)? = nil) {
        do {
            try Task.run(bash: command)
            completion?(true)
        } catch {
            completion?(false)
        }
    }
}

let main = command(
    Option("path", default: "./MultiOSVersionSnapshot.yml", description: "The path of MultiOSVersionSnapFile")
) { path in
    let multiOSVersionSnapFile = MultiOSVersionSnapshot()
    multiOSVersionSnapFile.run(ymlPath: path)
}
main.run()
