# Trusted Sources

Use these sources first for technical research. Prefer primary documentation over summaries.

## Source selection rules

- Prefer official vendor docs, language specs, and primary proposals.
- Prefer source repositories and package docs for project dependencies.
- Prefer Apple docs and Swift evolution notes for platform/language behavior.
- Treat community blogs as secondary and verify against primary sources.
- If sources conflict, defer to official platform/language references.

## Trusted web sources

### Apple platform and API references

- https://developer.apple.com/documentation/
- https://developer.apple.com/design/human-interface-guidelines/
- https://developer.apple.com/app-store/review/guidelines/
- https://developer.apple.com/videos/

### Swift language and tooling

- https://www.swift.org/documentation/
- https://www.swift.org/blog/
- https://docs.swift.org/swift-book/documentation/the-swift-programming-language/
- https://github.com/swiftlang/swift-evolution
- https://github.com/swiftlang/swift-package-manager
- https://github.com/swiftlang/swift-testing

### First-party project references

- https://actionstatus.elegantchaos.com/
- Local repo docs under `Extras/Documentation/`
- Local package READMEs under `Core/**/README.md`

## Trusted MCP resources

When available in session, prefer these MCP-backed sources before web search:

- `mcp__cupertino__search_docs`
  - Apple docs, Swift docs, and Swift Evolution indexed via MCP.
- `mcp__cupertino__read_document`
  - Read the matched primary document directly.
- `mcp__cupertino__search_samples`
  - Apple sample code discovery for implementation patterns.
- `mcp__cupertino__read_sample` and `mcp__cupertino__read_sample_file`
  - Inspect sample README/code directly.

## Secondary sources (use with caution)

These can help with context, but require verification:

- Hacking With Swift (https://www.hackingwithswift.com/)
- Swift Forums (https://forums.swift.org/)
- Apple Developer Forums (https://developer.apple.com/forums/)

Do not treat secondary sources as final authority for API contracts, platform policy, or language semantics.
