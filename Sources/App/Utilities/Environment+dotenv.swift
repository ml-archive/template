//
// Adaption of extension from vapor-community/vapor-ext
// Repo: https://github.com/vapor-community/vapor-ext
// File: ./Sources/ServiceExt/Environment%2BDotEnv.swift
//
import Foundation
import Service

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

// MARK: - Methods

public extension Environment {
    /// Loads environment variables from .env files.
    ///
    /// - Parameter filename: name of your env file.
    static func dotenv(filename: String = ".env") {
        guard let path = getAbsolutePath(for: filename),
            let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }

        let lines = contents.split(whereSeparator: { $0 == "\n" || $0 == "\r\n" })

        for line in lines {
            // ignore comments
            if line.starts(with: "#") {
                continue
            }

            // ignore lines that appear empty
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }

            // extract key and value which are separated by an equals sign
            guard
                // has to contain at least one "="
                let indexOfKeyValueSeparator = line.firstIndex(of: "="),
                // line must not start with "=" (ie. key must not be empty)
                indexOfKeyValueSeparator != line.startIndex
            else {
                continue
            }

            let key = String(line.prefix(upTo: indexOfKeyValueSeparator))
                .trimmingCharacters(in: .whitespacesAndNewlines)

            var value = String(line.suffix(from: line.index(after: indexOfKeyValueSeparator)))
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // remove surrounding quotes from value &
            // convert remove escape character before any embedded quotes
            if
                value[value.startIndex] == "\"",
                value[value.index(before: value.endIndex)] == "\""
            {
                value.remove(at: value.startIndex)
                value.remove(at: value.index(before: value.endIndex))
                value = value.replacingOccurrences(of: "\\\"", with: "\"")
            }

            // remove surrounding single quotes from value
            // & convert remove escape character before any embedded quotes
            if
                value[value.startIndex] == "'",
                value[value.index(before: value.endIndex)] == "'"
            {
                value.remove(at: value.startIndex)
                value.remove(at: value.index(before: value.endIndex))
                value = value.replacingOccurrences(of: "\\'", with: "'")
            }

            setenv(key, value, 1)
        }
    }

    /// Determine absolute path of the given argument relative to the current directory.
    ///
    /// - Parameter relativePath: relative path of the file.
    /// - Returns: the absolute path if exists.
    private static func getAbsolutePath(for filename: String) -> String? {
        let fileManager = FileManager.default
        let currentPath = DirectoryConfig.detect().workDir.finished(with: "/")
        let filePath = currentPath + filename
        if fileManager.fileExists(atPath: filePath) {
            return filePath
        } else {
            return nil
        }
    }
}
