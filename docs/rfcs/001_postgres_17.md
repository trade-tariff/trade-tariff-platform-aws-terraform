# Request for Change (RFC): Migration from Amazon Aurora PostgreSQL 16.8 to 17.5

## Overview

This RFC proposes a major version upgrade of the Amazon Aurora PostgreSQL database from engine version 16.8 to 17.5. The upgrade will leverage our existing infrastructure and deployment processes to ensure zero downtime. The change will be executed outside of peak hours at 6:30 PM London time (BST/GMT depending on the season) to minimize any potential impact on users.

## Description

The migration involves upgrading the Aurora PostgreSQL-Compatible Edition cluster to version 17.5, which is based on PostgreSQL 17. This includes applying community-driven enhancements along with Aurora-specific optimizations. No schema changes or data migrations are required beyond the engine upgrade, assuming application compatibility with PostgreSQL 17 features and behaviors.

## Justification

Upgrading to Aurora PostgreSQL 17.5 provides access to significant improvements in performance, security, and functionality from the PostgreSQL 17 release, as well as Aurora-specific enhancements. Key benefits include:

- **Performance Improvements**:
  - Up to 20x reduction in memory usage for vacuum operations, leading to faster vacuum speeds and reduced resource contention in high-load environments.
  - Up to 2x better write throughput for high-concurrency workloads through optimized WAL processing.
  - Enhanced query execution with optimizations for IN clauses using B-tree indexes, parallel BRIN index builds, and SIMD support (including AVX-512) for functions like bit_count.
  - Faster bulk operations, such as 2x improved exporting of large rows via COPY, and streaming I/O for sequential scans and ANALYZE commands.
  - Aurora-specific: Improved memory management and optimized write-heavy workloads on Graviton4 instances, along with faster storage metadata initialization during failovers.

- **New Features and Functionality**:
  - Enhanced SQL/JSON support, including JSON_TABLE for converting JSON to relational tables, new constructors (JSON, JSON_SCALAR, JSON_SERIALIZE), and query functions (JSON_EXISTS, JSON_QUERY, JSON_VALUE).
  - Improvements to the MERGE command with RETURNING clause and view updates.
  - COPY command now includes an ON_ERROR option to handle insert errors without halting imports.
  - Better support for partitioned tables with identity columns and exclusion constraints.
  - Logical replication enhancements, including failover control and the pg_createsubscriber tool for converting physical replicas to logical ones, simplifying upgrades without data resynchronization.
  - Incremental backups via pg_basebackup and pg_combinebackup for more efficient data management.
  - New monitoring tools, such as EXPLAIN options for I/O timing and memory usage, vacuum progress reporting, and the pg_wait_events view.
  - Updated extensions in Aurora: pgvector 0.8.0 for improved vector search capabilities and postgis 3.5.1 for geospatial enhancements.

- **Security and Stability Enhancements**:
  - New TLS support with direct handshakes using ALPN (Application-Layer Protocol Negotiation) for stronger secure connections.
  - Built-in, platform-independent collation provider for consistent UTF-8 sorting, reducing inconsistencies across environments.
  - Aurora-specific security fixes and bug resolutions from the community, addressing issues like optimized reads cache functionality and recovery times after failovers.

These updates address potential vulnerabilities, improve operational efficiency, and enable new capabilities that can enhance application performance and developer productivity. Staying on the latest major version also ensures continued support and access to future patches.

## Risks and Mitigations

- **Compatibility Issues**: PostgreSQL 17 introduces query plan changes and new behaviors (e.g., in logical replication). Mitigation: Perform thorough testing in a staging environment prior to production upgrade.
- **Replication Errors**: Data replication to the new database may encounter issues. Mitigation: Validate the ECS replication script and monitor logs during the process.
- **Configuration Errors**: Incorrect database URL propagation to backends. Mitigation: Verify Terraform outputs and secrets configuration before deployment.
- **Resource Usage**: New optimizations may alter CPU/memory patterns. Mitigation: Monitor metrics post-upgrade using Amazon CloudWatch.
- Overall risk level: Low, given the managed infrastructure and zero-downtime deployment strategy.

## Implementation Plan

1. **Preparation**:
   - Deploy a new Aurora PostgreSQL 17.5 database cluster using Terraform, specifying the updated engine version.
   - Use the ECS script from https://github.com/trade-tariff/trade-tariff-tools/blob/main/bin/ecs to replicate the latest production data to the new database via the backend-job ECS service.
   - Update secrets configurations for the four backends (worker-uk, worker-xi, backend-uk, backend-xi) to include the new database URL generated by Terraform and stored in the database URL secret.

2. **Execution**:
   - Deploy the four backends (worker-uk, worker-xi, backend-uk, backend-xi) using an A/B deployment strategy to ensure zero downtime.
   - Monitor logs and performance during the deployment to confirm successful switchover to the new database.

3. **Post-Implementation**:
   - Run a full end-to-end (E2E) test suite against the production environment to validate functionality and performance.
   - Verify database operations and application behavior with the new version.
   - Update any monitoring alerts or automation scripts for Aurora PostgreSQL 17.5.

## Testing Plan

- Validate the new database instance in a staging environment with a subset of production data.
- Run regression tests on queries, stored procedures, and application workloads against the new database.
- Validate key features like logical replication and JSON handling if applicable.
- Perform load testing to ensure performance gains are realized without regressions.
- Execute a full E2E test run post-deployment to confirm production stability.

## Rollback Plan

- If issues arise, revert the backend deployments to the previous configuration pointing to the Aurora PostgreSQL 16.8 cluster.
- Maintain the original 16.8 cluster until full validation of the 17.5 deployment is complete, allowing quick failback.
- Restore from a pre-upgrade snapshot if needed, though this may involve brief downtime as a last resort.

## Schedule

- **Proposed Date/Time**: Start of November at 6:30 PM London time.
- **Duration**: Expected 1-2 hours for database deployment, replication, backend deployment, and validation but during the actual migration only about 10 minutes for the switchover.
- **Approval Required By**: [Neil]
