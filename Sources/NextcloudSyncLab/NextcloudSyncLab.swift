import ArgumentParser
import Foundation
import MCP
import NextcloudContainerManager

@main
struct NextcloudSyncLab: AsyncParsableCommand {
    mutating func run() async throws {
        let server = Server(name: "NextcloudSyncLab", version: "1.0.0", capabilities: .init(tools: .init(listChanged: true)))
        let transport = StdioTransport()
        try await server.start(transport: transport)

        await server.withMethodHandler(ListTools.self) { _ in
            let containerId = stringParam("Container ID returned by start_server")
            let app = stringParam("App identifier, e.g. \"calendar\"")
            let user = stringParam("User identifier / login name")
            let tools = [
                Tool(
                    name: "start_server",
                    description: "Deploy a new Nextcloud server container. Set push_notifications to enable the High Performance Backend; the assigned push port is included in the result.",
                    inputSchema: objectSchema(
                        properties: [
                            "version": stringParam("Nextcloud server version release tag"),
                            "push_notifications": boolParam("Enable the High Performance Backend (push notifications). Defaults to false."),
                        ]
                    )
                ),
                Tool(
                    name: "stop_server",
                    description: "Stop and delete a Nextcloud server container",
                    inputSchema: objectSchema(properties: ["id": containerId], required: ["id"])
                ),
                Tool(
                    name: "install_app",
                    description: "Install a Nextcloud app (occ app:install) in a running container",
                    inputSchema: objectSchema(properties: ["app": app, "id": containerId], required: ["app", "id"])
                ),
                Tool(
                    name: "uninstall_app",
                    description: "Uninstall a Nextcloud app (occ app:remove) from a running container",
                    inputSchema: objectSchema(properties: ["app": app, "id": containerId], required: ["app", "id"])
                ),
                Tool(
                    name: "enable_app",
                    description: "Enable an installed Nextcloud app (occ app:enable) in a running container",
                    inputSchema: objectSchema(properties: ["app": app, "id": containerId], required: ["app", "id"])
                ),
                Tool(
                    name: "disable_app",
                    description: "Disable a Nextcloud app (occ app:disable) in a running container",
                    inputSchema: objectSchema(properties: ["app": app, "id": containerId], required: ["app", "id"])
                ),
                Tool(
                    name: "add_user",
                    description: "Create a Nextcloud user (occ user:add) in a running container. The initial password is set equal to the username (test environments only).",
                    inputSchema: objectSchema(properties: ["user": user, "id": containerId], required: ["user", "id"])
                ),
                Tool(
                    name: "remove_user",
                    description: "Remove a Nextcloud user (occ user:delete) from a running container",
                    inputSchema: objectSchema(properties: ["user": user, "id": containerId], required: ["user", "id"])
                ),
                Tool(
                    name: "enable_user",
                    description: "Enable a Nextcloud user (occ user:enable) in a running container",
                    inputSchema: objectSchema(properties: ["user": user, "id": containerId], required: ["user", "id"])
                ),
                Tool(
                    name: "disable_user",
                    description: "Disable a Nextcloud user (occ user:disable) in a running container",
                    inputSchema: objectSchema(properties: ["user": user, "id": containerId], required: ["user", "id"])
                ),
                Tool(
                    name: "fetch_logs",
                    description: "Fetch the Nextcloud application log (data/nextcloud.log, newline-delimited JSON) from a running container. Returns the last `lines` entries (default 100); pass lines=0 for the full log. Point-in-time snapshot.",
                    inputSchema: objectSchema(
                        properties: [
                            "id": containerId,
                            "lines": intParam("Number of trailing log lines to return; default 100, use 0 for the entire log"),
                        ],
                        required: ["id"]
                    )
                ),
            ]
            return .init(tools: tools)
        }

        await server.withMethodHandler(CallTool.self) { params in
            switch params.name {
            case "start_server":
                let tag = params.arguments?["version"]?.stringValue ?? "latest"
                let pushNotifications = params.arguments?["push_notifications"]?.boolValue ?? false
                let configuration = NextcloudConfiguration(tag: tag, pushNotifications: pushNotifications)
                let container = try await NextcloudContainerManager.deploy(configuration: configuration)
                var text = "Container ID: \(container.id)\nURL: http://localhost:\(container.port)"
                if let pushPort = container.pushPort {
                    text += "\nPush notifications port: \(pushPort)"
                }
                return .init(content: [.text(text: text, annotations: nil, _meta: nil)], isError: false)

            case "stop_server":
                guard let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required argument: id", annotations: nil, _meta: nil)], isError: true)
                }
                try await NextcloudContainerManager.delete(id)
                return .init(content: [.text(text: "Container \(id) stopped and deleted", annotations: nil, _meta: nil)], isError: false)

            case "install_app":
                guard let app = params.arguments?["app"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: app, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.addApp(app, inContainer: id)
                    return .init(content: [.text(text: "Installed app \(app) in container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to install app \(app): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "uninstall_app":
                guard let app = params.arguments?["app"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: app, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.removeApp(app, inContainer: id)
                    return .init(content: [.text(text: "Uninstalled app \(app) from container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to uninstall app \(app): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "enable_app":
                guard let app = params.arguments?["app"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: app, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.enableApp(app, inContainer: id)
                    return .init(content: [.text(text: "Enabled app \(app) in container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to enable app \(app): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "disable_app":
                guard let app = params.arguments?["app"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: app, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.disableApp(app, inContainer: id)
                    return .init(content: [.text(text: "Disabled app \(app) in container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to disable app \(app): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "add_user":
                guard let user = params.arguments?["user"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: user, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.addUser(user, inContainer: id)
                    return .init(content: [.text(text: "Created user \(user) in container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to create user \(user): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "remove_user":
                guard let user = params.arguments?["user"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: user, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.removeUser(user, inContainer: id)
                    return .init(content: [.text(text: "Removed user \(user) from container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to remove user \(user): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "enable_user":
                guard let user = params.arguments?["user"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: user, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.enableUser(user, inContainer: id)
                    return .init(content: [.text(text: "Enabled user \(user) in container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to enable user \(user): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "disable_user":
                guard let user = params.arguments?["user"]?.stringValue,
                      let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required arguments: user, id", annotations: nil, _meta: nil)], isError: true)
                }
                do {
                    try await NextcloudContainerManager.disableUser(user, inContainer: id)
                    return .init(content: [.text(text: "Disabled user \(user) in container \(id)", annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to disable user \(user): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            case "fetch_logs":
                guard let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required argument: id", annotations: nil, _meta: nil)], isError: true)
                }
                let limit = params.arguments?["lines"]?.intValue ?? 100
                do {
                    let url = try await NextcloudContainerManager.logFile(inContainer: id)
                    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
                    let content = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                    let lines = content.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
                    let selected = limit <= 0 ? lines : Array(lines.suffix(limit))
                    let header = "nextcloud.log (container \(id)) — showing \(selected.count) of \(lines.count) line(s):"
                    let body = selected.isEmpty ? "(log is empty)" : selected.joined(separator: "\n")
                    return .init(content: [.text(text: header + "\n" + body, annotations: nil, _meta: nil)], isError: false)
                } catch {
                    return .init(content: [.text(text: "Failed to fetch logs for container \(id): \(error)", annotations: nil, _meta: nil)], isError: true)
                }

            default:
                return .init(content: [.text(text: "Unknown tool", annotations: nil, _meta: nil)], isError: true)
            }
        }

        await server.waitUntilCompleted()
    }
}

/// Builds the JSON Schema fragment for a single required/optional string property.
private func stringParam(_ description: String) -> Value {
    .object([
        "type": .string("string"),
        "description": .string(description),
    ])
}

/// Builds the JSON Schema fragment for a single integer property.
private func intParam(_ description: String) -> Value {
    .object([
        "type": .string("integer"),
        "description": .string(description),
    ])
}

/// Builds the JSON Schema fragment for a single boolean property.
private func boolParam(_ description: String) -> Value {
    .object([
        "type": .string("boolean"),
        "description": .string(description),
    ])
}

/// Builds a JSON Schema `object` with the given properties, omitting `required` when empty.
private func objectSchema(properties: [String: Value], required: [String] = []) -> Value {
    var schema: [String: Value] = [
        "type": .string("object"),
        "properties": .object(properties),
    ]
    if !required.isEmpty {
        schema["required"] = .array(required.map { .string($0) })
    }
    return .object(schema)
}
