#!/bin/bash
set -x

awslocal ses verify-email-identity --email admin@example.com

set +x