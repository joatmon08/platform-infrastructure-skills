---
name: platform-compliance
description: Skill for reviewing architecture of cloud infrastructure like AWS EC2, VPC, load balancers, RDS, S3, OpenSearch, and EKS with infrastructure as code and Terraform. Use when the user asks about the security, cost, and compliance of cloud infrastructure according to an organization's standards.
---

# Platform Compliance Skill

## Overview

Design and architect cloud infrastructure that is secure, production-ready, and
compliant with organization standards. 

Provide a security code review, compliance evaluation, and cost assessment of the cloud infrastructure deployed by Terraform.

Output the plan for deploying and implementing infrastructure in a proposal document called `COMPLIANCE_REVIEW.md`.

---

## Phase 1: Security Review

Perform a code review on the Terraform configuration
and provide a list of suggestions on how to improve its security.

Consider:

- Encryption at rest and in transit
- IAM roles and policies (principle of least privilege)
- Network security (security groups, NACLs)
- Secrets management (AWS Secrets Manager usage)
- Public exposure of resources
- Logging and monitoring configuration

Before proceeding to Phase 2, verify:
- [ ] User has acknowledged security findings and recommendations

## Phase 2: Compliance Evaluation

Evaluate the Terraform configuration for compliance according to
the organization's policies.

Verify the following:

- [ ] All resources have required tags (ManagedBy, Environment, OwnedBy, BusinessUnit, Project, Purpose)
- [ ] Secrets stored in AWS Secrets Manager (not hardcoded)
- [ ] No public modules used (only private vetted modules)
- [ ] Kubernetes resources use Helm charts unless otherwise noted

## Phase 3: Cost Estimation

Use Infracost CLI to provide cost estimates for the deployed infrastructure and
write it to a file:

```bash
infracost breakdown --path . --format table > MONTHLY_COST.md
```

If Infracost CLI provides a $0.00 cost estimate, verify with AWS pricing.

**Cost Analysis Guidelines:**
- Include monthly cost estimates in the review
- Highlight any resources with significant costs (>$100/month)
- Note any resources with variable costs based on usage
- If Infracost cannot estimate a resource, note "Cost unknown - manual review required"
- Provide cost optimization recommendations from Infracost output

### Checklist

- [ ] User has corrected high-priority issues based on recommendations
- [ ] User has justified high-priority violations with inline comment
      ```
      ## Justification: The Helm chart does not contain overrides for an Ingress configuration.
      ```

### Example

Refer to `EXAMPLE.md` for a full example of how to structure the compliance review.

## Recovery

If the user does not remediate as per `COMPLIANCE_REVIEW.md`, prompt the user for feedback and suggest
escalation to the security team.