---
name: vault-secrets-engine-designer
description: Guide for designing secrets engine plugins for IBM Vault (HashiCorp Vault). Vault plugins enable secrets management and credentials rotation by creating and revoking passwords, API tokens, certificates, JWTs, and encryption keys. Use when you want to design and architect a secrets engine and the behavior of the plugin, not implementation with Vault's Go SDK.
---

# IBM Vault Secrets Engine Designer

Design secrets engine plugins for credential lifecycle management. Output: `ARCHITECTURE.md`

## Prerequisites

**REQUIRED: Request from user before starting:**
1. Service API documentation (URL or file path)
2. Authentication method for service API
3. Credential types needed (tokens, keys, certificates)
4. Any known limitations or constraints

## Design Process

### 1. API Analysis

Review service API documentation for:
- Credential creation/deletion endpoints
- Token/key lifecycle (create, update, revoke)
- Identity model (user, team, organization scopes)
- Authentication requirements
- Rate limits or constraints

**Decision Points:**
- Can service create/delete multiple credentials? → Dynamic secrets
- Only one credential at a time? → Static secrets (needs rotate-role endpoint)
- No deletion endpoint? → Static secrets (returns same credential)

**Reuse Existing Engines:**
- Encryption keys → [transit engine](https://developer.hashicorp.com/vault/docs/secrets/transit)
- Certificates → [PKI engine](https://developer.hashicorp.com/vault/docs/secrets/pki)
- JWTs → [identity engine](https://developer.hashicorp.com/vault/docs/secrets/identity)

### 2. Domain Mapping

Map service API to Vault domain model:

| Vault Concept | Purpose | Required Fields |
|---------------|---------|-----------------|
| **Config** | Service API connection | `address`, `token`, `default_ttl`, `default_max_ttl` (dynamic only) |
| **Role** | Permission template | Identity attributes, `ttl`, `max_ttl` (dynamic only) |
| **Credentials** | Secret generation | Varies by service API |

**Identity Mapping:**
- Global/team/user scopes → Role configuration options
- Permission groups/policies → Role attributes
- IP restrictions/metadata → Role constraints

### 3. API Endpoints

Define Vault API interface:

```
POST   <mount>/config              # Configure service connection
GET    <mount>/config              # Read configuration
POST   <mount>/roles/:name         # Create/update role
GET    <mount>/roles/:name         # Read role
LIST   <mount>/roles               # List roles
DELETE <mount>/roles/:name         # Delete role
GET    <mount>/creds/:role         # Generate credentials
POST   <mount>/rotate-root         # Rotate root credentials (optional)
POST   <mount>/rotate-role/:name   # Rotate static credentials (static only)
```

## ARCHITECTURE.md Template

```markdown
# [Service] Secrets Engine

[Brief description of what credentials this engine manages]

## Service API Summary
- Base URL: [URL]
- Authentication: [method]
- Credential Types: [list]
- Lifecycle: [create/update/delete capabilities]

## Configuration

POST <mount>/config
{
  "address": "https://api.service.com",
  "token": "service-api-token",
  "default_ttl": 3600,        # dynamic only
  "default_max_ttl": 86400    # dynamic only
}

## Roles

POST <mount>/roles/:name
{
  "ttl": 3600,                # dynamic only
  "max_ttl": 86400,           # dynamic only
  [service-specific fields]
}

## Credentials

GET <mount>/creds/:role
Response (dynamic):
{
  "lease_id": "<mount>/creds/:role/...",
  "lease_duration": 3600,
  "renewable": true,
  "data": {
    [credential fields]
  }
}

Response (static):
{
  "data": {
    [credential fields]
  }
}

## Implementation Notes

### Service API Calls
- Create: [endpoint and method]
- Update: [endpoint and method] # if supported
- Delete: [endpoint and method]

### Lease Renewal
[Describe renewal behavior for dynamic secrets]

### Revocation
[Describe revocation process]

### Error Handling
[Known error conditions and handling]

## Security Considerations
- [List security concerns]
- [Credential storage notes]
- [Permission requirements]
```

## Checklist

Before completing:
- [ ] All service API endpoints mapped to Vault operations
- [ ] Revocation path confirmed for dynamic secrets
- [ ] Identity/permission model clearly defined
- [ ] Lease renewal behavior specified (dynamic only)
- [ ] Error conditions documented
- [ ] Security considerations noted

## References
- [Backend](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-backend)
- [Config](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-config)
- [Roles](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-role)
- [Credentials](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-creds)