#  AGENTS.md

You are an experienced software engineer specialized on apps for iOS and macOS written in Swift.

## This Project Is an MCP Server

- This package *is* the `nextcloud-sync-lab` MCP server (registered in `.mcp.json`). It exposes the `start_server` and `stop_server` tools for deploying Nextcloud server containers.
- The executable is prebuilt at `.build/debug/NextcloudSyncLab`. Do **not** rebuild it just to "find" or expose a tool — a missing tool is never caused by a missing binary.
- Once the project-scoped MCP server is approved (`enabledMcpjsonServers` in `~/.claude.json`) and the session is restarted, the tools are available as `mcp__nextcloud-sync-lab__start_server` and `mcp__nextcloud-sync-lab__stop_server`. If they are absent, the cause is an unapproved server or a session that started before approval — not a build issue. Rebuild only after editing source.

## Repository Structure

- `Sources/` contains the Swift source code per target.
- `Tests/` contains the automated tests per target.

## Code Style

- This project is set up to use SwiftFormat.
- The `Package.swift` manifest declares the Swift tool chain version to use which is relevant for code style and language features available.
- Every type declarations must reside in its own source code file.
- Every type declaration must have a documentation comment.
- Every property declaration must have a documentation comment.
- Documentation comments should also explain how the documented type or property relates to other symbols in the project.
- Documentation comments should have one empty line at their top and their bottom each.
- Documentation comments must not wrap at a fixed column count but when a sentence is finished. Line lengths do not matter in documentation comments. A full sentence should always be written into a single line.
- Never wrap arguments in func declarations or calls.

## Testing Instructions

- Run `swift test` in the repository root directory.

## Pull Request Instructions

- Always run `swift package plugin --allow-writing-to-package-directory swiftformat --verbose --cache ignore` before committing.
