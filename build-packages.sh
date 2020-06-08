#!/bin/bash
set -e
echo "Starting PSI CI - pricing-aggregator build"

(cd ./packages/pricing-aggregator && npm ci)
(cd ./packages/pricing-aggregator && npm run test-ci)