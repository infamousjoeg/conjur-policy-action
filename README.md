# Conjur Policy as Code GitHub Action <!-- omit from toc -->

This GitHub Action automatically loads Conjur Policy as Code from your repository using Conjur's JWT Authenticator. It allows you to manage your Conjur policies as code directly in your GitHub repository and automatically apply them using the GitHub Actions workflow.

## Table of Contents <!-- omit from toc -->
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Basic Example](#basic-example)
  - [Inputs](#inputs)
- [Setting up Conjur JWT Authentication for GitHub Actions](#setting-up-conjur-jwt-authentication-for-github-actions)
  - [1. Configure Conjur JWT Authenticator](#1-configure-conjur-jwt-authenticator)
  - [2. Set the JWT Authenticator Variables](#2-set-the-jwt-authenticator-variables)
  - [3. Create Host Identity for GitHub Actions](#3-create-host-identity-for-github-actions)
  - [4. Add Host to JWT Authenticator Users Group](#4-add-host-to-jwt-authenticator-users-group)
- [Security Best Practices](#security-best-practices)
- [OIDC Authentication Details](#oidc-authentication-details)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [License](#license)


## Features

- 🔒 Securely authenticates to Conjur using JWT (JSON Web Token) authentication with GitHub's OIDC tokens
- 📁 Loads policy files from your repository to Conjur
- 🌟 Supports glob patterns for finding policy files
- 🧩 Follows GitHub Actions best practices for security and implementation
- 🐛 Provides detailed debugging options

## Prerequisites

Before using this action, you need to:

1. Configure Conjur to use JWT authentication
2. Set up a JWT authenticator with the appropriate service ID
3. Configure the JWT authenticator to trust GitHub's OIDC issuer
4. Define a host identity in Conjur that will be used by the GitHub Action
5. Grant the necessary permissions to the host identity to load policies

## Usage

### Basic Example

```yaml
name: Deploy Conjur Policies

on:
  push:
    branches: [ main ]
    paths:
      - 'policies/**'

jobs:
  deploy-policies:
    runs-on: ubuntu-latest
    
    # Required for OIDC authentication to Conjur
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Load Conjur Policies
        uses: your-org/conjur-policy-action@v1
        with:
          conjur_url: ${{ secrets.CONJUR_URL }}
          conjur_account: ${{ secrets.CONJUR_ACCOUNT }}
          conjur_authn_jwt_service_id: github
          conjur_policy_branch: root
          policy_paths: 'policies/**/*.yml'
```

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `conjur_url` | URL of the Conjur instance | Yes | - |
| `conjur_account` | Conjur account name | Yes | - |
| `conjur_authn_jwt_service_id` | Service ID for Conjur JWT Authenticator | Yes | - |
| `conjur_policy_branch` | Conjur policy branch to load policies into | Yes | - |
| `policy_paths` | Paths to policy files relative to repository root (glob pattern supported) | Yes | `policies/**/*.yml` |
| `debug` | Enable debug output | No | `false` |

## Setting up Conjur JWT Authentication for GitHub Actions

To use this action, you need to configure Conjur to authenticate GitHub Actions workflows using JWT tokens.

### 1. Configure Conjur JWT Authenticator

First, load a policy to enable the JWT authenticator in Conjur:

```yaml
# enable-github-jwt-auth.yml
- !policy
  id: conjur/authn-jwt/github
  body:
    - !webservice
    
    - !variable
      id: jwks-uri
    
    - !variable
      id: token-app-property
    
    - !variable
      id: identity-path
    
    - !variable
      id: issuer
    
    - !group
      id: users
    
    - !permit
      role: !group users
      privilege: [ read, authenticate ]
      resource: !webservice
```

### 2. Set the JWT Authenticator Variables

Configure the JWT authenticator to work with GitHub Actions:

```bash
# Set the JWKS URI for GitHub
conjur variable set -i conjur/authn-jwt/github/jwks-uri -v "https://token.actions.githubusercontent.com/.well-known/jwks"

# Set the issuer to match GitHub's token issuer
conjur variable set -i conjur/authn-jwt/github/issuer -v "https://token.actions.githubusercontent.com"

# Configure the identity path
conjur variable set -i conjur/authn-jwt/github/identity-path -v "host/github-actions"

# Set the token app property
conjur variable set -i conjur/authn-jwt/github/token-app-property -v "repository"
```

### 3. Create Host Identity for GitHub Actions

Create a host identity that will be used by GitHub Actions:

```yaml
# github-actions-host.yml
- !policy
  id: github-actions
  body:
    - !policy
      id: repo
      body:
        - !policy
          id: your-org/your-repo
          body:
            - !host
            
            # Grant necessary permissions for policy loading
            - !permit
              role: !host
              privilege: [ read, update ]
              resource: !policy root
```

### 4. Add Host to JWT Authenticator Users Group

```yaml
# add-host-to-jwt-users.yml
- !grant
  role: !group conjur/authn-jwt/github/users
  member: !host github-actions/repo/your-org/your-repo
```

## Security Best Practices

This action follows GitHub Actions security best practices:

1. Uses the least privilege principle for permissions
2. Does not expose secrets in logs or environment variables
3. Validates all inputs before use
4. Uses the GitHub OIDC token for authentication instead of long-lived credentials
5. Implements proper error handling and validation

## OIDC Authentication Details

This action uses GitHub's OpenID Connect (OIDC) token to authenticate to Conjur. When configured correctly, GitHub generates a short-lived OIDC token for your workflow that Conjur can validate using GitHub's JWKS endpoint.

The claims in the OIDC token include:

- `sub`: A unique identifier for the workflow run
- `aud`: The audience (always "https://github.com/YOUR-ORG/YOUR-REPO")
- `iss`: The issuer (always "https://token.actions.githubusercontent.com")
- `repository`: The repository name (e.g., "your-org/your-repo")
- Additional claims related to the workflow, job, and runner

## Troubleshooting

If you encounter issues with the action, try the following:

1. Enable debug mode by setting `debug: true` in the action inputs
2. Check Conjur logs for authentication failures
3. Verify that your JWT authenticator is correctly configured
4. Make sure the host identity has the necessary permissions

## Development

To contribute to this action:

1. Clone the repository
2. Make your changes
3. Test your changes using the GitHub Actions workflow in the `.github/workflows/test.yml` file

## License

This project is licensed under the MIT License - see the LICENSE file for details.