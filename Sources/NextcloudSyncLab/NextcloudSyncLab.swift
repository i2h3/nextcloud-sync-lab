import ArgumentParser
import MCP
import NextcloudContainerManager

@main
struct NextcloudSyncLab: AsyncParsableCommand {
    mutating func run() async throws {
        let server = Server(name: "NextcloudSyncLab", version: "1.0.0", capabilities: .init(tools: .init(listChanged: true)))
        let transport = StdioTransport()
        try await server.start(transport: transport)

        await server.withMethodHandler(ListTools.self) { _ in
            let tools = [
                Tool(
                    name: "start_server",
                    description: "Deploy a new Nextcloud server container",
                    inputSchema: .object([
                        "type": .string("object"),
                        "properties": .object([
                            "version": .object([
                                "type": .string("string"),
                                "description": .string("Nextcloud server version release tag"),
                            ]),
                        ]),
                    ])
                ),
                Tool(
                    name: "stop_server",
                    description: "Stop and delete a Nextcloud server container",
                    inputSchema: .object([
                        "type": .string("object"),
                        "properties": .object([
                            "id": .object([
                                "type": .string("string"),
                                "description": .string("Container ID returned by start_server"),
                            ]),
                        ]),
                        "required": .array([.string("id")])
                    ])
                ),
            ]
            return .init(tools: tools)
        }

        await server.withMethodHandler(CallTool.self) { params in
            switch params.name {
            case "start_server":
                let tag = params.arguments?["version"]?.stringValue ?? "latest"
                let configuration = NextcloudConfiguration(tag: tag)
                let container = try await NextcloudContainerManager.deploy(configuration: configuration)
                let text = "Container ID: \(container.id)\nURL: http://localhost:\(container.port)"
                return .init(content: [.text(text: text, annotations: nil, _meta: nil)], isError: false)

            case "stop_server":
                guard let id = params.arguments?["id"]?.stringValue else {
                    return .init(content: [.text(text: "Missing required argument: id", annotations: nil, _meta: nil)], isError: true)
                }
                try await NextcloudContainerManager.delete(id)
                return .init(content: [.text(text: "Container \(id) stopped and deleted", annotations: nil, _meta: nil)], isError: false)

            default:
                return .init(content: [.text(text: "Unknown tool", annotations: nil, _meta: nil)], isError: true)
            }
        }

        await server.waitUntilCompleted()
    }
}
