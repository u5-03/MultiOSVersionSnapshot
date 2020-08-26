//
//  YmlEntity.swift
//  MultiOSVersionSnapshot
//
//  Created by Yugo Sugiyama on 2020/07/12.
//

import Foundation

public struct YmlEntity: Decodable {
    public let osVersions: [String]
    public let outputDirectory: String
    public let snapshotExecutableCommand: String?
    public let shouldGeneratePDF: Bool
    public let pdfTitlePrefix: String
    public let snapshot: [String: Any]

    enum CodingKeys: String, CodingKey {
        case osVersions
        case outputDirectory
        case snapshotExecutableCommand
        case shouldGeneratePDF
        case pdfTitlePrefix
        case snapshot
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        osVersions = try container.decode([String].self, forKey: .osVersions)
        outputDirectory = try container.decode(String.self, forKey: .outputDirectory)
        snapshotExecutableCommand = try container.decodeIfPresent(String.self, forKey: .snapshotExecutableCommand)
        shouldGeneratePDF = try container.decodeIfPresent(Bool.self, forKey: .shouldGeneratePDF) ?? false
        pdfTitlePrefix = try container.decodeIfPresent(String.self, forKey: .pdfTitlePrefix) ?? "screenshots"
        snapshot = try container.decode([String: Any].self, forKey: .snapshot)
    }
}
