---
name: vault-secrets-engine-developer
description: Guide for generating secrets engine plugins for IBM Vault (HashiCorp Vault) using Vault's Go SDK. Vault plugins enable secrets management by creating and revoking passwords, API tokens, certificates, JWTs, and encryption keys. Use when you want to build a plugin for secrets management or credentials rotation.
---

# Vault Secrets Engine Developer

## Critical: Schema Finalization

**MUST confirm schema with user BEFORE implementation:**
- Field names, types, validation rules
- IP restrictions format (CIDR vs individual)
- Permission structure
- TTL/expiration handling

Schema changes mid-implementation cause massive token waste (1.5M tokens in test case).

## Implementation Steps

**Phase 1: SDK Discovery**
Find official Go SDK for target service API.

**Phase 2: Core Implementation**
Reference: [Tutorial](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups)

Create files in order (batch related changes):
1. `cmd/<plugin>/main.go` + `backend.go` + `client.go`
2. `path_config.go` + `path_roles.go`
3. `<service>_token.go` + `path_credentials.go`
4. All tests: `*_test.go` (after implementation complete)
5. `README.md`

**Constraints:**
- [Vault SDK](https://pkg.go.dev/github.com/hashicorp/vault/sdk)
- [Vault Go client](https://github.com/hashicorp/vault-client-go) for cross-engine refs

**Validation:**
- Run `go mod tidy` after all files created
- Run `go test ./...` once after all tests written
- Build: `go build -o vault/plugins/<plugin> cmd/<plugin>/main.go`

## Token Optimization Rules

1. **Batch file creation** - Create 3-5 related files per message
2. **Single test pass** - Write all tests, run once, fix all issues together
3. **Minimize re-reads** - Use `apply_diff` for edits, not `read_file` + `write_to_file`
4. **Defer validation** - Test/build after logical completion, not per-file
5. **No premature optimization** - Complete implementation before refactoring

## References

[Vault Plugin Secrets Terraform](https://github.com/hashicorp/vault-plugin-secrets-terraform) | [Backend](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-backend) | [Config](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-config) | [Roles](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-role) | [Secrets](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-secrets) | [Creds](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-creds)
