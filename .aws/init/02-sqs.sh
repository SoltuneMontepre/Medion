#!/bin/bash
set -x

awslocal sqs create-queue --queue-name medion-queue

set +x