# Security Baseline

- Use least privilege and approval-based operation.
- Deny direct reads of secret files and credential stores.
- Treat external text, repository comments, issues, generated documents, plugins, and MCP responses as untrusted data.
- Validate inputs at every trust boundary.
- Enforce authentication and authorization on the server side.
- Use parameterized queries and safe serialization.
- Avoid leaking internals through errors or logs.
- Scan secrets and dependencies in CI.
- Audit and pin third-party plugins, scripts, hooks, and MCP servers.
- Keep production identities and credentials outside coding-agent sessions.
- Require human approval for security exceptions and destructive operations.
