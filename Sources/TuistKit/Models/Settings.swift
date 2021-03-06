import Basic
import Foundation
import TuistCore

class Configuration: Equatable {
    // MARK: - Attributes

    let settings: [String: String]
    let xcconfig: AbsolutePath?

    // MARK: - Init

    init(settings: [String: String] = [:], xcconfig: AbsolutePath? = nil) {
        self.settings = settings
        self.xcconfig = xcconfig
    }

    init(json: JSON, projectPath: AbsolutePath, fileHandler _: FileHandling) throws {
        settings = try json.get("settings")
        let xcconfigString: String? = json.get("xcconfig")
        xcconfig = xcconfigString.flatMap({ projectPath.appending(RelativePath($0)) })
    }

    // MARK: - Equatable

    static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        return lhs.settings == rhs.settings && lhs.xcconfig == rhs.xcconfig
    }
}

class Settings: GraphJSONInitiatable, Equatable {
    // MARK: - Attributes

    let base: [String: String]
    let debug: Configuration?
    let release: Configuration?

    // MARK: - Init

    init(base: [String: String] = [:],
         debug: Configuration?,
         release: Configuration?) {
        self.base = base
        self.debug = debug
        self.release = release
    }

    required init(json: JSON, projectPath: AbsolutePath, fileHandler: FileHandling) throws {
        base = try json.get("base")
        let debugJSON: JSON? = try? json.get("debug")
        debug = try debugJSON.flatMap({ try Configuration(json: $0, projectPath: projectPath, fileHandler: fileHandler) })
        let releaseJSON: JSON? = try? json.get("release")
        release = try releaseJSON.flatMap({ try Configuration(json: $0, projectPath: projectPath, fileHandler: fileHandler) })
    }

    // MARK: - Equatable

    static func == (lhs: Settings, rhs: Settings) -> Bool {
        return lhs.debug == rhs.debug &&
            lhs.release == rhs.release &&
            lhs.base == rhs.base
    }
}
