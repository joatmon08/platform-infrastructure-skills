---
name: vault-secrets-engine-developer
description: Guide for generating secrets engine plugins for IBM Vault (HashiCorp Vault) using Vault's Go SDK. Vault plugins enable secrets management by creating and revoking passwords, API tokens, certificates, JWTs, and encryption keys. Use when you want secrets management or credentials rotation.
---

# IBM Vault Secrets Engine Developer

## Overview

Create a secrets engine plugin based on an architecture description.

## Process

### Phase 1: Go SDK for service API

Find an official Go SDK for the service API.

### Phase 2: Implementation

1. Set up project structure: [Tutorial Code Example](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups)
2. Implement client SDK for service API if an official SDK doesn't exist
3. Implement [`cmd/<plugin>/main.go`](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups/blob/main/cmd/vault-plugin-secrets-hashicups/main.go)
4. Implement [backend](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups/blob/main/backend.go)
5. Implement [configuration](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups/blob/main/path_config.go)
6. Implement [role](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups/blob/main/path_roles.go)
7. Create helper methods for [credentials rotation](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups/blob/main/hashicups_token.go)
8. Implement [credentials endpoint](https://github.com/hashicorp-education/learn-vault-plugin-secrets-hashicups/blob/main/path_credentials.go).
9. Generate unit tests for `path_config_test.go`
10. Generate unit tests for `path_role_test.go`
11. Generate unit tests for `path_credentials_test.go`
12. Generate placeholder for acceptance tests in `backend_test.go``

Constraints:

- Use [Vault SDK](https://pkg.go.dev/github.com/hashicorp/vault/sdk)
- If you need to reference another secrets engine in Vault, use the [Vault Go client library](https://github.com/hashicorp/vault-client-go)

Checklist:

- [ ] Unit tests for all `path_` files.
- [ ] Run `go test ./...` after each test generation step. If go test fails, review test output, fix the implementation, and re-run before proceeding to the next step.
- [ ] Compiles with `go build -o vault/plugins/vault-plugin-secrets-hashicups cmd/vault-plugin-secrets-hashicups/main.go`

### Phase 3: Documentation

Create a `README.md` that explains how to build the plugin and add it to Vault.

Checklist:

- [ ] `README.md` file includes plugin registration and example commands.

## References

- [HCP Terraform/Terraform Enterprise Secrets Engine](https://github.com/hashicorp/vault-plugin-secrets-terraform)
- [Define a backend for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-backend)
- [Define a configuration for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-config)
- [Define roles for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-role)
- [Implement secrets for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-secrets)
- [Define credentials for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-creds)
