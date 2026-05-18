---
name: vault-secrets-engine-designer
description: Guide for designing secrets engine plugins for IBM Vault (HashiCorp Vault). Vault plugins enable secrets management and credentials rotation by creating and revoking passwords, API tokens, certificates, JWTs, and encryption keys. Use when you want to design and architect a secrets engine and the behavior of the plugin, not implementation with Vault's Go SDK.
---

# IBM Vault Secrets Engine Designer

## Overview

Design secrets engine plugins that allow Vault to create and revoke passwords, API tokens, certificates, JWTs, and encryption keys. This skill writes the intended design
to `ARCHITECTURE.md`.

## Process

### Phase 1: Research

1. Review the service's API documentation for credential or token endpoints, authentication requirements, and identities.
2. Determine you need to extend an existing Vault secrets engine or require a new Vault secrets engine.
  - If the service API needs an encryption key, consider using Vault's [transit secrets engine](https://developer.hashicorp.com/vault/docs/secrets/transit)
    to generate a key.
  - If the service API needs a certificate, consider using Vault's [PKI secrets engine](https://developer.hashicorp.com/vault/docs/secrets/pki) to generate a certificate.
  - If the service API needs a JWT, consider configuring Vault's [identity secrets engine](https://developer.hashicorp.com/vault/docs/secrets/identity) to populate the claims.
3. If the service API can only generate one secret at a time, the secrets engine manages static secrets. If a service API can create and delete secrets, the secrets engine can be dynamic.
4. Beware of multiple IDs in the same system
5. Check if generating credentials leads to unintended revocation from the service API

Checklist:
- [ ] Outline any uncertainties in architecture or credential issuance
- [ ] Make note of calls to other Vault secrets engines, as they require a Vault token for access

### Phase 2: Domain Modeling

Vault has the following domain model for secrets engines.

- Backend: Physical storage of secrets.
- Configuration: Configuration for the secrets engine, including authentication to service API.
- Role: Identity with a set of permissions, groups, or policies you want to attach a user of the secrets engine.
- Credentials: Secret created or deleted by Vault using the service API.

Determine which domain model elements are relevant to the service API.

- If a service API has an identity domain model with global, team, and user-scoped credentials,
  set the global, team, or user identifier as options in the role.
- If a service API only generates one token at a time, note that you need to create a `rotate-role` endpoint
  for a user to call Vault to manually rotate the credentials.
- If a service API has no endpoint to delete credentials, note that the secrets engine returns the same credential
  like a database static role.

Checklist:
-[] Verify each credential endpoint maps to a real service API call and confirm revocation paths exist for dynamic secrets.

### Phase 3: API Interface

- `<path>/config`: describe how secrets engine connects to service API. Required fields for dynamic secrets: `default_ttl`, `default_max_ttl`
- `<path>/role/<name>`: describe how secrets engine creates and deletes credentials. Include user, group, or other identity attributes. Required fields for dynamic secrets: `ttl`, `max_ttl`
- `<path>/creds/<role-name>`: describe how secrets engine rotates credentials

Checklist:
- [ ] Verify each credential endpoint maps to a real service API call and confirm revocation paths exist for dynamic secrets.

## Example

Below is the example `ARCHITECTURE.md`.

```markdown
# HCP Terraform Secrets Engine

This secrets engine creates and deletes HCP Terraform API tokens.

## Configuration

```text
POST terraform/config
Body:
{
  address: https://app.terraform.io,
  token: abc-1234,
  default_ttl: 3600,
  default_max_ttl: 5200
}
Response: 204 No Content
```

## Role

```text
POST terraform/roles/:team_role_name
Body:
{
  team_id: tf-team-1234,
  ttl: 3600,
  max_ttl: 5200,
  organization: my-unique-tf-org, # optional
}
Response: 204 No Content
```

```text
GET terraform/roles/:team_role_name
Response: 200 OK
{
  team-id: tf-team-1234,
  ttl: 3600,
  max_ttl: 5200,
  organization: my-unique-tf-org,
}
```

## Credentials

### Generate team token

Team tokens are static secrets and do not have a lease.

```text
GET terraform/creds/:team_role_name
Response: 200 OK
{
# no lease fields
  "data": {
    "token_id": "team-132ae3ef"
    "token": "132ae3ef-5a64-7499-351e-bfe59f3a2a21"
  },
}
```

### Generate user token

User tokens are dynamic and have a lease.

```text
GET terraform/creds/:user_role_name
Response: 200 OK
{
  # lease fields
  lease_id: terraform/creds/my-user-role/HZ8edrojluU1fzVy7GWoIUpo,
  lease_duration:3600,
  data: {
    token_id: "user-132ae3ef"
    token: 132ae3ef-5a64-7499-351e-bfe59f3a2a21,
  }
}
```

```

## References

- [Define a backend for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-backend)
- [Define a configuration for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-config)
- [Define roles for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-role)
- [Implement secrets for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-secrets)
- [Define credentials for the secrets engine](https://developer.hashicorp.com/vault/tutorials/custom-secrets-engine/custom-secrets-engine-creds)
