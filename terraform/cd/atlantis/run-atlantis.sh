#!/bin/bash
REPO_ALLOWLIST="github.com/bananalab/Learn-Infrastructure-as-Code-with-Terraform"
./atlantis server \
--atlantis-url="$URL" \
--gh-user="$GH_USERNAME" \
--gh-token="$GH_TOKEN" \
--gh-webhook-secret="$SECRET" \
--repo-allowlist="$REPO_ALLOWLIST"