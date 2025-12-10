# Twelve-Factor Implementation Plan for iDempiere

**Target Application:** iDempiere ERP/CRM/SCM System  
**Location:** `git/idempiere-2025-11-08/`  
**Implementation Method:** Agentic Engineering using Cursor  
**Analysis Reference:** `12-factor/` directory  
**Twelve-Factor Principles:** https://www.12factor.net/

---

## Executive Summary

This document provides a detailed implementation plan to modernize the iDempiere application to achieve full compliance with the Twelve-Factor App methodology. The plan is specifically designed for agentic engineers using Cursor AI to systematically upgrade the application.

**Current State:** ~42% compliance (5/12 factors fully compliant)  
**Target State:** 100% compliance (12/12 factors)  
**Estimated Duration:** 7-13 months (includes Phase 0: Test Harness Setup)  
**Critical Blockers:** Factors III (Config), V (Build/Release/Run), VI (Processes), X (Dev/Prod Parity), XI (Logs)  
**Critical Prerequisite:** Automated test harness MUST be established before any application changes

---

## Prerequisites

### Required Knowledge
- Twelve-Factor App principles (https://www.12factor.net/)
- Java/OSGi application architecture
- Maven/Tycho build system
- Docker and containerization
- Kubernetes (for later phases)
- Redis (for state externalization)

### Analysis Documents
Before starting implementation, review:
- `12-factor/README.md` - Executive summary and overall assessment
- `12-factor/DETAILED_ANALYSIS.md` - Technical deep dive with code references
- `12-factor/MIGRATION_ROADMAP.md` - Phased approach overview
- `12-factor/QUICK_REFERENCE.md` - Quick lookup guide

### Application Structure
- **Root:** `git/idempiere-2025-11-08/`
- **Base Module:** `org.adempiere.base/` - Core utilities and models
- **Server Module:** `org.adempiere.server/` - Server-side components
- **Server Feature:** `org.adempiere.server-feature/` - Server deployment artifacts
- **Build System:** Maven with Tycho for OSGi bundles

---

## Implementation Strategy for Agentic Engineers

### Critical Principle: Test-First Approach
**NO APPLICATION CHANGES SHOULD BE MADE UNTIL PHASE 0 (TEST HARNESS) IS COMPLETE**

Before modifying any application code:
1. **Phase 0 must be complete:** Automated test harness must be operational
2. **Baseline established:** All existing tests must pass
3. **CI/CD pipeline ready:** Tests must run automatically on every change
4. **Test coverage baseline:** Document current test coverage

### Principles
1. **Test-First:** Automated test harness established before any changes (Phase 0)
2. **Incremental Changes:** Make small, testable changes
3. **Backward Compatibility:** Maintain compatibility during transition
4. **Test-Driven:** Write tests before/alongside changes
5. **Documentation:** Update docs with each change
6. **Code Search First:** Use codebase search to understand context before modifying

### Workflow
1. **Understand:** Use `codebase_search` to understand current implementation
2. **Plan:** Review analysis documents and identify specific files
3. **Implement:** Make focused changes with clear acceptance criteria
4. **Test:** Verify changes work and don't break existing functionality
5. **Document:** Update relevant documentation

---

## Phase 0: Test Harness Setup (2-4 weeks) ⚠️ CRITICAL PREREQUISITE

**Priority:** **CRITICAL - BLOCKER FOR ALL OTHER PHASES**  
**Effort:** Medium-High  
**Risk:** Medium  
**Status:** **MUST BE COMPLETED BEFORE ANY APPLICATION CHANGES**

### Overview

**This phase establishes a comprehensive automated test harness that MUST be operational before any application code modifications begin.** This ensures:
- Regression detection for all changes
- Safe refactoring with confidence
- Continuous validation of application behavior
- Baseline metrics for comparison

**NO PHASE 1-6 WORK SHOULD BEGIN UNTIL PHASE 0 IS COMPLETE AND VERIFIED.**

### 0.1 Enable Existing Test Suite

**Goal:** Activate and verify existing test infrastructure

**Current State:**
- Test module exists: `org.idempiere.test/`
- Tests use JUnit 5 (Jupiter)
- Tests are currently skipped: `<skipTests>true</skipTests>`
- ~117 test files exist covering models, forms, processes, etc.
- Tests require OSGi/Tycho runtime and database

**Files to Modify:**
- `org.idempiere.test/pom.xml` - Enable test execution
- Test database setup scripts
- CI/CD configuration

**Implementation Steps:**

1. **Enable test execution:**
   - Set `<skipTests>false</skipTests>` in `org.idempiere.test/pom.xml`
   - Verify test dependencies are available
   - Configure test database connection

2. **Set up test database:**
   - Create dedicated test database instance
   - Run database migrations for test schema
   - Seed test data (GardenWorld demo data)
   - Document database setup process

3. **Run existing tests:**
   - Execute test suite: `mvn test -pl org.idempiere.test`
   - Document test results and failures
   - Fix any environment/setup issues
   - Establish baseline: "X tests passing, Y tests failing"

4. **Create test execution documentation:**
   - Document how to run tests locally
   - Document test database setup
   - Document test environment requirements

**Acceptance Criteria:**
- [ ] Test execution enabled (`skipTests=false`)
- [ ] Test database configured and accessible
- [ ] All existing tests can be executed
- [ ] Baseline test results documented (pass/fail counts)
- [ ] Test execution documented for team
- [ ] Tests can be run via Maven command

**Human Activity:**
- **Agentic Engineer:** Enable tests, configure database, run baseline
- **DevOps Engineer:** Set up test database infrastructure
- **QA Engineer:** Review test results, document baseline
- **Time Estimate:** 1-2 weeks

---

### 0.2 CI/CD Pipeline for Tests

**Goal:** Automate test execution in CI/CD pipeline

**Files to Create/Modify:**
- `.github/workflows/test.yml` (or GitLab CI, Jenkins, etc.)
- `scripts/run-tests.sh`
- `scripts/setup-test-db.sh`

**Implementation Steps:**

1. **Create CI/CD pipeline:**
   - Configure GitHub Actions / GitLab CI / Jenkins
   - Set up test database in CI environment
   - Configure test execution on every commit/PR
   - Set up test result reporting

2. **Create test scripts:**
   - Script to set up test database
   - Script to run test suite
   - Script to generate test reports

3. **Configure test reporting:**
   - JUnit XML reports
   - Test coverage reports (JaCoCo)
   - Test result notifications

4. **Set up test environment:**
   - Docker Compose for test database
   - Test environment variables
   - Test data seeding

**Acceptance Criteria:**
- [ ] CI/CD pipeline runs tests on every commit
- [ ] Tests run on pull requests
- [ ] Test results visible in CI/CD dashboard
- [ ] Test failures block merges (configurable)
- [ ] Test coverage reports generated
- [ ] Test execution time < 30 minutes

**Human Activity:**
- **DevOps Engineer:** Set up CI/CD pipeline, configure infrastructure
- **Agentic Engineer:** Create test scripts, configure test execution
- **Time Estimate:** 1 week

---

### 0.3 Test Coverage Baseline

**Goal:** Establish baseline test coverage metrics

**Files to Create:**
- `docs/TEST_COVERAGE_BASELINE.md`
- Test coverage configuration

**Implementation Steps:**

1. **Configure test coverage tool:**
   - Set up JaCoCo or similar coverage tool
   - Configure coverage thresholds
   - Generate coverage reports

2. **Establish baseline:**
   - Run coverage analysis on existing code
   - Document coverage by module/package
   - Identify gaps in test coverage
   - Set coverage goals for migration

3. **Create coverage dashboard:**
   - Track coverage over time
   - Set minimum coverage thresholds
   - Report coverage in CI/CD

**Acceptance Criteria:**
- [ ] Test coverage tool configured
- [ ] Baseline coverage documented
- [ ] Coverage reports generated automatically
- [ ] Coverage tracked in CI/CD
- [ ] Coverage goals defined

**Human Activity:**
- **Agentic Engineer:** Configure coverage tools, generate baseline
- **QA Engineer:** Analyze coverage, set goals
- **Time Estimate:** 3-5 days

---

### 0.4 Integration Test Framework

**Goal:** Set up integration test framework for twelve-factor changes

**Files to Create:**
- `org.idempiere.test.integration/` (new test module)
- Integration test base classes
- Test utilities for configuration testing
- Test utilities for health check testing

**Implementation Steps:**

1. **Create integration test module:**
   - New Maven module for integration tests
   - Separate from unit tests
   - Configure for OSGi/Tycho execution

2. **Create test utilities:**
   - `ConfigTestHelper` - Test environment variable configuration
   - `HealthCheckTestHelper` - Test health check endpoints
   - `LoggingTestHelper` - Test logging output
   - `ContainerTestHelper` - Test Docker container execution

3. **Create base integration test class:**
   - Extend `AbstractTestCase`
   - Add utilities for twelve-factor testing
   - Configure test environment

4. **Create sample integration tests:**
   - Test configuration loading from env vars
   - Test health check endpoints
   - Test logging to stdout
   - Test container execution

**Acceptance Criteria:**
- [ ] Integration test module created
- [ ] Test utilities available
- [ ] Base integration test class available
- [ ] Sample integration tests created
- [ ] Integration tests can be run independently

**Human Activity:**
- **Agentic Engineer:** Create test framework, write utilities
- **QA Engineer:** Review test framework, provide feedback
- **Time Estimate:** 1 week

---

### 0.5 Test Data Management

**Goal:** Establish test data management strategy

**Files to Create:**
- `test-data/` directory structure
- Test data seeding scripts
- Test data cleanup scripts

**Implementation Steps:**

1. **Create test data structure:**
   - Organize test data by test type
   - Create test data fixtures
   - Document test data requirements

2. **Create data seeding scripts:**
   - Scripts to seed test database
   - Scripts to reset test data
   - Scripts to create test scenarios

3. **Create data cleanup scripts:**
   - Scripts to clean up after tests
   - Scripts to reset database state
   - Scripts to isolate test data

**Acceptance Criteria:**
- [ ] Test data structure organized
- [ ] Test data seeding scripts available
- [ ] Test data cleanup scripts available
- [ ] Test data isolated between tests
- [ ] Test data documented

**Human Activity:**
- **Agentic Engineer:** Create test data scripts
- **QA Engineer:** Review test data strategy
- **Time Estimate:** 3-5 days

---

### Phase 0 Completion Criteria

Phase 0 is complete when:
- [ ] All existing tests can be executed
- [ ] CI/CD pipeline runs tests automatically
- [ ] Test coverage baseline established
- [ ] Integration test framework ready
- [ ] Test data management in place
- [ ] All Phase 0 acceptance criteria met
- [ ] Team trained on test execution
- [ ] Documentation complete

**Only after Phase 0 completion should Phase 1 begin.**

---

## Phase 1: Quick Wins (1-2 weeks)

**Priority:** High  
**Effort:** Low  
**Risk:** Low

### 1.1 Port Configuration via Environment Variable

**Goal:** Make HTTP port configurable via `PORT` environment variable

**Files to Modify:**
- `org.adempiere.server-feature/idempiere-server.sh` (or `.bat` for Windows)
- Jetty configuration files in `org.adempiere.server-feature/jettyhome/etc/`

**Implementation Steps:**

1. **Search for current port configuration:**
   ```bash
   # Use codebase_search to find where port is configured
   ```
   Query: "How is the HTTP port configured for Jetty server?"

2. **Modify startup script:**
   - Read `PORT` environment variable
   - Default to 8080 if not set
   - Pass to Jetty via system property or configuration

3. **Update Jetty configuration:**
   - Ensure Jetty uses the configured port
   - Support both HTTP and HTTPS port configuration

**Acceptance Criteria:**
- [ ] Application starts on port specified by `PORT` env var
- [ ] Defaults to 8080 if `PORT` not set
- [ ] Works in containerized environment
- [ ] Both HTTP and HTTPS ports configurable

**Testing:**
```bash
# Test with custom port
PORT=9090 ./idempiere-server.sh
# Verify application accessible on port 9090
```

---

### 1.2 Health Check Endpoints

**Goal:** Add health check endpoints for Kubernetes/container orchestration

**Files to Create/Modify:**
- Create: `org.adempiere.server/src/main/servlet/org/compiere/web/HealthCheckServlet.java`
- Modify: `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java` (register servlet)

**Implementation Steps:**

1. **Create HealthCheckServlet:**
   - `/health` - Liveness probe (process running)
   - `/health/ready` - Readiness probe (ready for requests)
   - `/health/startup` - Startup probe (startup complete)

2. **Register servlet in OSGi:**
   - Add servlet registration in OSGi service registry
   - Map to appropriate URL paths

3. **Implement checks:**
   - Liveness: Always return 200 if process running
   - Readiness: Check database connection, cluster service (if enabled)
   - Startup: Check if initialization complete

**Acceptance Criteria:**
- [ ] `/health` returns 200 if process running
- [ ] `/health/ready` returns 200 when ready, 503 when not ready
- [ ] `/health/startup` returns 200 when startup complete
- [ ] Endpoints respond quickly (< 1 second)
- [ ] Endpoints work without authentication

**Code Reference:**
- See `AdempiereMonitor.java` for servlet registration pattern
- Use `DB.isConnected()` for database check
- Use `ClusterServerMgr.getClusterService()` for cluster check

---

### 1.3 Startup Optimization

**Goal:** Reduce startup time and make cluster service optional

**Files to Modify:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java` (lines 1396-1439)

**Implementation Steps:**

1. **Add configuration option:**
   - `IDEMPIERE_CLUSTER_ENABLED` environment variable
   - Default to `false` for single-instance deployments

2. **Reduce wait times:**
   - Reduce `MONITOR_INITIAL_WAIT_FOR_CLUSTER_IN_SECONDS` default from 10 to 5
   - Reduce `MONITOR_MAX_WAIT_FOR_CLUSTER_IN_SECONDS` default from 180 to 30

3. **Skip cluster wait if disabled:**
   - Check `IDEMPIERE_CLUSTER_ENABLED` before waiting
   - If disabled, proceed immediately

**Acceptance Criteria:**
- [ ] Startup completes in < 60 seconds for single instance
- [ ] Cluster wait can be disabled via `IDEMPIERE_CLUSTER_ENABLED=false`
- [ ] Application works without cluster service
- [ ] Backward compatible (cluster still works if enabled)

**Code Location:**
```java
// File: org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java
// Lines: 1396-1439
// Current: Waits up to 180 seconds for cluster service
// Target: Skip wait if cluster disabled, reduce max wait to 30s
```

---

### 1.4 Logging Redirect (Partial)

**Goal:** Add stdout logging alongside file logging

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/CLogFile.java`
- Logging configuration

**Implementation Steps:**

1. **Search for logging implementation:**
   ```bash
   # Use codebase_search
   ```
   Query: "How are log files written and where is CLogFile implemented?"

2. **Add stdout handler:**
   - Add ConsoleHandler to logging configuration
   - Configure to write to stdout
   - Keep file handler for backward compatibility

3. **Make file logging optional:**
   - Add `IDEMPIERE_LOG_TO_FILE` environment variable
   - Default to `true` for backward compatibility
   - If `false`, only log to stdout

**Acceptance Criteria:**
- [ ] Logs appear in both files and stdout
- [ ] File logging can be disabled via `IDEMPIERE_LOG_TO_FILE=false`
- [ ] No breaking changes to existing functionality
- [ ] Log levels configurable

**Testing:**
```bash
# Test with file logging disabled
IDEMPIERE_LOG_TO_FILE=false ./idempiere-server.sh
# Verify logs appear in stdout but not in files
```

---

## Phase 2: Configuration Refactoring (1-2 months)

**Priority:** Critical  
**Effort:** High  
**Risk:** Medium

### 2.1 Environment Variable Support

**Goal:** Refactor configuration to read from environment variables first

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/Ini.java` (primary file)
- `org.adempiere.base/src/org/compiere/util/Env.java` (context variables)

**Key Code Locations:**
```java
// File: org.adempiere.base/src/org/compiere/util/Ini.java
// Current: Reads from idempiere.properties file
// Target: Read from environment variables first, fallback to file
```

**Implementation Steps:**

1. **Understand current implementation:**
   - Search: "How does Ini.java load configuration from properties file?"
   - Review `getFileName()` and `loadProperties()` methods
   - Understand property key naming conventions

2. **Create environment variable mapper:**
   - Map property keys to environment variable names
   - Convention: `IDEMPIERE_<PROPERTY_KEY>` (uppercase, underscores)
   - Example: `Connection` → `IDEMPIERE_CONNECTION`

3. **Modify property loading:**
   - Check environment variable first
   - Fallback to properties file if env var not set
   - Maintain backward compatibility

4. **Support database connection variables:**
   - `IDEMPIERE_DB_TYPE` (postgresql/oracle)
   - `IDEMPIERE_DB_HOST`
   - `IDEMPIERE_DB_PORT`
   - `IDEMPIERE_DB_NAME`
   - `IDEMPIERE_DB_USER`
   - `IDEMPIERE_DB_PASSWORD`
   - `IDEMPIERE_DB_URL` (alternative: full connection string)

**Environment Variables to Support:**

```bash
# Database Configuration
IDEMPIERE_DB_TYPE=postgresql
IDEMPIERE_DB_HOST=localhost
IDEMPIERE_DB_PORT=5432
IDEMPIERE_DB_NAME=idempiere
IDEMPIERE_DB_USER=adempiere
IDEMPIERE_DB_PASSWORD=secret
IDEMPIERE_DB_URL=postgresql://user:pass@host:port/dbname  # Alternative format

# Application Configuration
IDEMPIERE_HOME=/opt/idempiere
IDEMPIERE_PORT=8080
IDEMPIERE_TRACE_LEVEL=WARNING
IDEMPIERE_TRACE_FILE=
IDEMPIERE_LANGUAGE=en_US

# Clustering
IDEMPIERE_CLUSTER_ENABLED=false
IDEMPIERE_CLUSTER_WAIT_SECONDS=10
IDEMPIERE_CLUSTER_MAX_WAIT_SECONDS=30

# Security
IDEMPIERE_APPLICATION_USER_ID=GardenAdmin
IDEMPIERE_APPLICATION_PASSWORD=GardenAdmin
IDEMPIERE_STORE_PASSWORD=

# Logging
IDEMPIERE_LOG_TO_FILE=true
IDEMPIERE_LOG_LEVEL=INFO
```

**Acceptance Criteria:**
- [ ] All configuration can be set via environment variables
- [ ] Properties file still works for backward compatibility
- [ ] Environment variables take precedence over file
- [ ] Configuration validation at startup
- [ ] Clear error messages for missing required config
- [ ] Database connection works with env vars

**Testing:**
```bash
# Test with environment variables
export IDEMPIERE_DB_HOST=localhost
export IDEMPIERE_DB_PORT=5432
export IDEMPIERE_DB_NAME=idempiere
./idempiere-server.sh
# Verify application connects using env vars
```

---

### 2.2 Secrets Management

**Goal:** Remove password storage in properties file

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/SecureEngine.java`
- Configuration loading code

**Implementation Steps:**

1. **Identify password storage:**
   - Search for password storage in properties
   - Review encryption/decryption mechanisms

2. **Require passwords via environment:**
   - Database passwords must come from env vars
   - Application passwords from env vars
   - Fail startup if passwords in properties file

3. **Support secrets from files (optional):**
   - Support reading secrets from files (Kubernetes secrets)
   - `IDEMPIERE_DB_PASSWORD_FILE` - read password from file
   - Useful for containerized deployments

**Acceptance Criteria:**
- [ ] Passwords not stored in properties file
- [ ] Secrets can be provided via environment variables
- [ ] Support reading secrets from files
- [ ] No sensitive data in configuration files
- [ ] Clear error if required secrets missing

---

### 2.3 Configuration Validation

**Goal:** Validate all required configuration at startup

**Files to Create:**
- `org.adempiere.base/src/org/compiere/util/ConfigValidator.java`

**Implementation Steps:**

1. **Create configuration validator:**
   - Validate required configuration at startup
   - Check database connection parameters
   - Verify critical settings

2. **Fail fast:**
   - Exit with clear error if required config missing
   - List all missing configuration
   - Provide helpful error messages

**Acceptance Criteria:**
- [ ] Application fails to start with clear error if required config missing
- [ ] All configuration validated before use
- [ ] Error messages indicate which configuration is missing
- [ ] Validation happens early in startup

---

## Phase 3: Logging Refactoring (1 month)

**Priority:** High  
**Effort:** Medium  
**Risk:** Low

### 3.1 Stdout/Stderr Logging

**Goal:** Redirect all logs to stdout/stderr

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/CLogFile.java`
- All logging code

**Implementation Steps:**

1. **Understand current logging:**
   - Search: "How does CLogFile write logs to files?"
   - Review log file handler implementation

2. **Replace file handler with console handler:**
   - Redirect all logs to stdout
   - Redirect errors to stderr
   - Remove file system dependencies

3. **Make file logging optional:**
   - Keep file logging as optional feature
   - Disabled by default in containerized environments

**Acceptance Criteria:**
- [ ] All logs go to stdout
- [ ] All errors go to stderr
- [ ] File logging can be enabled via configuration
- [ ] No file system dependencies for logging
- [ ] Log rotation not required (handled by container)

---

### 3.2 Structured Logging

**Goal:** Implement JSON log format option

**Files to Modify:**
- Logging formatter
- Logging configuration

**Implementation Steps:**

1. **Add JSON formatter:**
   - Create JSON log formatter
   - Include standard fields (timestamp, level, message, etc.)
   - Add correlation IDs

2. **Make format configurable:**
   - `IDEMPIERE_LOG_FORMAT=json` or `text`
   - Default to text for backward compatibility

**Acceptance Criteria:**
- [ ] JSON log format available
- [ ] Correlation IDs in logs
- [ ] Standard log fields included
- [ ] Logs parseable by log aggregation tools
- [ ] Text format still available

---

### 3.3 Remove Log File Access

**Goal:** Remove web interface log file access

**Files to Modify:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java`

**Implementation Steps:**

1. **Remove file-based log access:**
   - Remove log file reading from web interface
   - Replace with log streaming endpoint

2. **Add log streaming:**
   - Create endpoint to stream recent logs
   - Support log aggregation services

**Acceptance Criteria:**
- [ ] No file system access for logs
- [ ] Log streaming endpoint available
- [ ] Compatible with cloud log aggregation
- [ ] Web interface still shows logs (from stream)

---

## Phase 4: Containerization (1-2 months)

**Priority:** High  
**Effort:** Medium  
**Risk:** Medium

### 4.1 Dockerfile Creation

**Goal:** Create multi-stage Dockerfile

**Files to Create:**
- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml` (for local development)

**Implementation Steps:**

1. **Create multi-stage Dockerfile:**
   ```dockerfile
   # Build stage
   FROM maven:3.8-eclipse-temurin-17 AS build
   WORKDIR /build
   COPY . .
   RUN mvn clean package -DskipTests

   # Release stage
   FROM eclipse-temurin:17-jre
   WORKDIR /opt/idempiere
   
   # Copy OSGi bundles and runtime
   COPY --from=build /build/org.adempiere.server-feature/target/products/org.adempiere.server.product/linux/gtk/x86_64/idempiereServer/plugins ./plugins/
   COPY --from=build /build/org.adempiere.server-feature/jettyhome ./jettyhome/
   
   # Environment variables
   ENV PORT=8080
   ENV IDEMPIERE_DB_TYPE=postgresql
   
   # Expose port
   EXPOSE ${PORT}
   
   # Health check
   HEALTHCHECK --interval=30s --timeout=3s \
     CMD curl -f http://localhost:${PORT}/health || exit 1
   
   # Start application
   CMD ["java", "-jar", "plugins/org.eclipse.equinox.launcher_*.jar", \
        "-application", "org.adempiere.server.application"]
   ```

2. **Create .dockerignore:**
   - Exclude build artifacts
   - Exclude IDE files
   - Exclude test files

**Acceptance Criteria:**
- [ ] Docker image builds successfully
- [ ] Image is immutable (no runtime changes)
- [ ] Configuration via environment variables
- [ ] Health checks working
- [ ] Image size optimized

**Testing:**
```bash
# Build image
docker build -t idempiere:latest .

# Run container
docker run -p 8080:8080 \
  -e IDEMPIERE_DB_HOST=db \
  -e IDEMPIERE_DB_NAME=idempiere \
  -e IDEMPIERE_DB_USER=adempiere \
  -e IDEMPIERE_DB_PASSWORD=secret \
  idempiere:latest
```

---

### 4.2 Build/Release/Run Separation

**Goal:** Separate build, release, and run stages

**Files to Create:**
- `scripts/build.sh`
- `scripts/release.sh`
- CI/CD pipeline configuration

**Implementation Steps:**

1. **Build stage:**
   - Maven/Tycho creates OSGi bundles
   - Runs tests
   - Creates build artifacts

2. **Release stage:**
   - Creates Docker image with all bundles
   - Tags image with version
   - No environment-specific data

3. **Run stage:**
   - Container starts with env vars
   - Configuration injected at runtime

**Acceptance Criteria:**
- [ ] Clear separation of stages
- [ ] Immutable release artifacts
- [ ] No configuration in image
- [ ] Environment-specific config at runtime

---

### 4.3 Kubernetes Manifests

**Goal:** Create Kubernetes deployment manifests

**Files to Create:**
- `k8s/deployment.yaml`
- `k8s/service.yaml`
- `k8s/configmap.yaml`
- `k8s/secrets.yaml`
- `k8s/ingress.yaml`

**Implementation Steps:**

1. **Create Deployment:**
   - Configure replicas (start with 1, will scale after stateless)
   - Health checks (liveness, readiness, startup)
   - Resource limits
   - Environment variables from ConfigMap/Secrets

2. **Create Service:**
   - Expose application
   - Load balancer or ClusterIP

3. **Create ConfigMap:**
   - Non-sensitive configuration
   - Environment-specific settings

4. **Create Secrets:**
   - Database credentials
   - Application passwords

**Acceptance Criteria:**
- [ ] Kubernetes deployment works
- [ ] Configuration via ConfigMap/Secrets
- [ ] Service exposes application
- [ ] Health checks configured
- [ ] Secrets properly managed

---

## Phase 5: Stateless Design (3-6 months)

**Priority:** Critical  
**Effort:** Very High  
**Risk:** High

### 5.1 Session State Externalization

**Goal:** Move sessions to Redis or database

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/model/MSession.java`
- `org.adempiere.base/src/org/compiere/util/Env.java`
- Session management code

**Implementation Steps:**

1. **Understand current session management:**
   - Search: "How are user sessions stored and managed?"
   - Review `MSession` class
   - Understand session lifecycle

2. **Choose external store:**
   - Option 1: Database (already used for some session data)
   - Option 2: Redis (better performance, dedicated cache)
   - Recommendation: Start with database, migrate to Redis later

3. **Externalize session storage:**
   - Remove in-memory session storage
   - Store all sessions in external store
   - Implement session retrieval by ID

4. **Update session access:**
   - Modify all code that accesses sessions
   - Ensure sessions accessible from any instance

**Acceptance Criteria:**
- [ ] Sessions stored externally (Redis/database)
- [ ] No in-memory session storage
- [ ] Sessions accessible from any instance
- [ ] Session cleanup working
- [ ] Performance acceptable

---

### 5.2 Context Externalization

**Goal:** Remove thread-local context storage

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/Env.java`
- `ServerContext` implementation
- All code using context

**Implementation Steps:**

1. **Understand context usage:**
   - Search: "How is ServerContext and thread-local context used?"
   - Review all context access patterns

2. **Pass context via request:**
   - Add context to request headers/parameters
   - Remove thread-local storage
   - Stateless request processing

3. **Update all context access:**
   - Modify all code that uses `Env.getCtx()`
   - Pass context explicitly
   - Remove thread-local dependencies

**Acceptance Criteria:**
- [ ] No thread-local context
- [ ] Context passed via request
- [ ] Stateless request processing
- [ ] Multiple instances work identically
- [ ] No session affinity required

---

### 5.3 Cache Externalization

**Goal:** Move caches to Redis

**Files to Modify:**
- Cache implementation
- Cache usage throughout codebase

**Implementation Steps:**

1. **Identify caches:**
   - Search: "Where are in-memory caches used?"
   - List all cache implementations

2. **Implement Redis cache:**
   - Add Redis client dependency
   - Create Redis cache implementation
   - Replace in-memory caches

3. **Update cache usage:**
   - Modify all cache access
   - Ensure shared cache across instances

**Acceptance Criteria:**
- [ ] All caches external (Redis)
- [ ] No in-memory caches
- [ ] Cache shared across instances
- [ ] Cache invalidation working
- [ ] Performance acceptable

---

### 5.4 Stateless Authentication

**Goal:** Implement JWT tokens

**Files to Modify:**
- Authentication code
- Authorization code
- Session management

**Implementation Steps:**

1. **Implement JWT:**
   - Add JWT library dependency
   - Create token generation/validation
   - Replace session-based auth

2. **Update authentication:**
   - Issue JWT on login
   - Validate JWT on each request
   - Remove session-based authentication

**Acceptance Criteria:**
- [ ] JWT-based authentication
- [ ] No session-based auth
- [ ] Stateless authorization
- [ ] Token validation working
- [ ] Token expiration handled

---

## Phase 6: Final Polish (1 month)

**Priority:** Medium  
**Effort:** Low-Medium  
**Risk:** Low

### 6.1 Dev/Prod Parity

**Goal:** Unify configuration mechanisms

**Files to Modify:**
- Development setup scripts
- Configuration code
- Documentation

**Implementation Steps:**

1. **Unify configuration:**
   - Use same environment variables in dev and prod
   - Remove dev-specific configuration files
   - Same setup process

2. **Containerize development:**
   - Use Docker for local development
   - Same container image for dev and prod
   - Environment-specific config via env vars

**Acceptance Criteria:**
- [ ] Same configuration in dev and prod
- [ ] Development uses containers
- [ ] Same setup process
- [ ] No environment-specific code

---

### 6.2 Admin Process Separation

**Goal:** Make all admin tasks independent

**Files to Modify:**
- Migration scripts
- Setup scripts
- Documentation

**Implementation Steps:**

1. **Make migrations independent:**
   - Database migrations as standalone scripts
   - No application context required
   - Can run in separate containers/jobs

2. **Containerize admin processes:**
   - Create separate Docker images for migrations
   - Kubernetes Jobs for one-off tasks
   - Same base image, different entry points

**Acceptance Criteria:**
- [ ] All admin tasks independent
- [ ] Can run in separate containers
- [ ] Well documented
- [ ] No application context required

---

### 6.3 Documentation

**Goal:** Complete documentation

**Files to Create:**
- `DEPLOYMENT.md`
- `ENVIRONMENT_VARIABLES.md`
- `MIGRATION_GUIDE.md`
- `RUNBOOKS.md`

**Implementation Steps:**

1. **Create deployment guide:**
   - How to deploy in containers
   - Kubernetes deployment
   - Environment configuration

2. **Document environment variables:**
   - Complete list of all env vars
   - Default values
   - Required vs optional

3. **Create migration guide:**
   - How to migrate from current state
   - Step-by-step instructions
   - Rollback procedures

**Acceptance Criteria:**
- [ ] Complete documentation
- [ ] Clear instructions
- [ ] Examples provided
- [ ] Up-to-date with implementation

---

## Testing Strategy

### Unit Tests
- Test configuration loading from environment variables
- Test session externalization
- Test stateless request processing

### Integration Tests
- Test database connection with env vars
- Test health check endpoints
- Test logging to stdout

### End-to-End Tests
- Test full deployment in container
- Test Kubernetes deployment
- Test horizontal scaling

### Performance Tests
- Test session externalization performance
- Test cache externalization performance
- Test startup time improvements

---

## Risk Mitigation

### Technical Risks

1. **Breaking Changes**
   - **Mitigation:** Maintain backward compatibility during transition
   - **Strategy:** Feature flags, gradual rollout

2. **Performance Impact**
   - **Mitigation:** Performance testing, optimization
   - **Strategy:** Benchmark before/after, optimize hot paths

3. **Migration Complexity**
   - **Mitigation:** Phased approach, incremental changes
   - **Strategy:** Small, testable changes, thorough testing

### Business Risks

1. **Downtime**
   - **Mitigation:** Blue-green deployments, gradual rollout
   - **Strategy:** Zero-downtime deployment process

2. **Resource Requirements**
   - **Mitigation:** Phased approach, prioritize critical factors
   - **Strategy:** Start with quick wins, demonstrate value

3. **User Impact**
   - **Mitigation:** Backward compatibility, gradual rollout
   - **Strategy:** User communication, feature flags

---

## Success Criteria

### Phase Completion
Each phase is complete when:
- [ ] All tasks completed
- [ ] Acceptance criteria met
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code reviewed

### Overall Success
Migration is successful when:
- [ ] All 12 factors compliant
- [ ] Application runs in cloud environment
- [ ] Horizontal scaling works
- [ ] No file system dependencies
- [ ] Configuration via environment variables
- [ ] Logs to stdout/stderr
- [ ] Health checks working
- [ ] Documentation complete

---

## Human Resources and Staffing

### Team Roles and Responsibilities

#### Agentic Engineers (Primary Implementers)
**Role:** Primary code implementation using Cursor AI  
**Responsibilities:**
- Implement code changes following the plan
- Write tests alongside code changes
- Use codebase search to understand context
- Make incremental, testable changes
- Update documentation with changes
- Run tests before committing changes

**Skills Required:**
- Java/OSGi development
- Maven/Tycho build systems
- Test-driven development
- Twelve-Factor App principles
- Experience with Cursor AI or similar tools

**Effort Allocation:**
- Phase 0: 40% of effort (test harness setup)
- Phase 1-6: 60-70% of implementation effort
- Ongoing: Code reviews, documentation updates

---

#### DevOps Engineers
**Role:** Infrastructure, CI/CD, containerization  
**Responsibilities:**
- Set up CI/CD pipelines
- Configure test database infrastructure
- Create Docker images and Kubernetes manifests
- Set up monitoring and logging infrastructure
- Manage deployment pipelines

**Skills Required:**
- CI/CD (GitHub Actions, GitLab CI, Jenkins)
- Docker and containerization
- Kubernetes
- Database administration
- Infrastructure as Code

**Effort Allocation:**
- Phase 0: 30% of effort (CI/CD setup)
- Phase 4: 80% of effort (containerization)
- Phase 5: 20% of effort (infrastructure for stateless design)
- Ongoing: Infrastructure maintenance

---

#### QA Engineers
**Role:** Test strategy, quality assurance, test validation  
**Responsibilities:**
- Review test coverage and quality
- Validate test results
- Set test coverage goals
- Review integration tests
- Validate acceptance criteria

**Skills Required:**
- Test strategy and planning
- Test automation
- Quality assurance processes
- Test coverage analysis

**Effort Allocation:**
- Phase 0: 20% of effort (test strategy, coverage analysis)
- Phase 1-6: 15-20% of effort (test validation, quality assurance)
- Ongoing: Test review and validation

---

#### Senior Software Engineers / Architects
**Role:** Technical leadership, architecture decisions, code review  
**Responsibilities:**
- Review architecture decisions
- Code review for critical changes
- Technical guidance and mentoring
- Risk assessment
- Performance analysis

**Skills Required:**
- Enterprise Java architecture
- OSGi framework expertise
- System design
- Performance optimization

**Effort Allocation:**
- Phase 0: 10% of effort (architecture review)
- Phase 2: 30% of effort (configuration refactoring review)
- Phase 5: 40% of effort (stateless design architecture)
- Ongoing: Code reviews, architecture guidance

---

#### Database Administrators
**Role:** Database setup, migrations, performance  
**Responsibilities:**
- Set up test databases
- Database migration support
- Performance optimization
- Database connection configuration

**Skills Required:**
- PostgreSQL/Oracle administration
- Database migration tools
- Performance tuning

**Effort Allocation:**
- Phase 0: 10% of effort (test database setup)
- Phase 2: 20% of effort (database configuration)
- Phase 5: 30% of effort (session externalization)
- Ongoing: Database maintenance

---

### Staffing Model

#### Minimum Viable Team (MVP)
- **1 Agentic Engineer** (full-time)
- **1 DevOps Engineer** (50% time)
- **1 QA Engineer** (25% time)
- **1 Senior Engineer** (25% time for reviews)

**Timeline Impact:** 12-18 months

#### Recommended Team
- **2 Agentic Engineers** (full-time)
- **1 DevOps Engineer** (full-time)
- **1 QA Engineer** (50% time)
- **1 Senior Engineer** (50% time)
- **1 DBA** (25% time)

**Timeline Impact:** 7-13 months (as estimated)

#### Optimal Team (Fastest)
- **3 Agentic Engineers** (full-time)
- **2 DevOps Engineers** (full-time)
- **2 QA Engineers** (full-time)
- **1 Senior Engineer** (full-time)
- **1 DBA** (50% time)

**Timeline Impact:** 5-8 months

---

### Human Activity by Phase

#### Phase 0: Test Harness Setup (2-4 weeks)
**Agentic Engineers:**
- Enable existing tests (3-5 days)
- Create integration test framework (5 days)
- Configure test coverage tools (2-3 days)
- Create test data scripts (3-5 days)
- **Total: 2-3 weeks full-time**

**DevOps Engineers:**
- Set up CI/CD pipeline (3-5 days)
- Configure test database infrastructure (2-3 days)
- **Total: 1 week full-time**

**QA Engineers:**
- Review test strategy (2 days)
- Analyze test coverage baseline (2-3 days)
- **Total: 1 week part-time**

**Total Human Effort:** ~4-5 person-weeks

---

#### Phase 1: Quick Wins (1-2 weeks)
**Agentic Engineers:**
- Port configuration (2-3 days)
- Health check endpoints (2-3 days)
- Startup optimization (1-2 days)
- Logging redirect (2-3 days)
- **Total: 1.5-2 weeks full-time**

**DevOps Engineers:**
- Review containerization readiness (1 day)
- **Total: 1 day**

**QA Engineers:**
- Test validation (2-3 days)
- **Total: 3 days part-time**

**Total Human Effort:** ~2-3 person-weeks

---

#### Phase 2: Configuration Refactoring (1-2 months)
**Agentic Engineers:**
- Environment variable support (2-3 weeks)
- Secrets management (1 week)
- Configuration validation (1 week)
- **Total: 4-5 weeks full-time**

**DevOps Engineers:**
- Review configuration approach (2-3 days)
- **Total: 3 days**

**QA Engineers:**
- Test validation (1 week)
- **Total: 1 week part-time**

**Senior Engineers:**
- Architecture review (1 week)
- Code review (ongoing)
- **Total: 1 week**

**Total Human Effort:** ~6-7 person-weeks

---

#### Phase 3: Logging Refactoring (1 month)
**Agentic Engineers:**
- Stdout/stderr logging (1 week)
- Structured logging (1 week)
- Remove log file access (1 week)
- **Total: 3 weeks full-time**

**QA Engineers:**
- Test validation (1 week)
- **Total: 1 week part-time**

**Total Human Effort:** ~3.5 person-weeks

---

#### Phase 4: Containerization (1-2 months)
**Agentic Engineers:**
- Dockerfile creation (1 week)
- Build/Release/Run separation (1 week)
- **Total: 2 weeks full-time**

**DevOps Engineers:**
- Dockerfile optimization (1 week)
- Kubernetes manifests (2 weeks)
- CI/CD integration (1 week)
- **Total: 4 weeks full-time**

**QA Engineers:**
- Container testing (1 week)
- **Total: 1 week part-time**

**Total Human Effort:** ~7 person-weeks

---

#### Phase 5: Stateless Design (3-6 months)
**Agentic Engineers:**
- Session state externalization (4-6 weeks)
- Context externalization (3-4 weeks)
- Cache externalization (2-3 weeks)
- Stateless authentication (2-3 weeks)
- **Total: 11-16 weeks full-time**

**DevOps Engineers:**
- Redis infrastructure (1 week)
- Load balancing setup (1 week)
- **Total: 2 weeks**

**QA Engineers:**
- Performance testing (2 weeks)
- Integration testing (2 weeks)
- **Total: 4 weeks part-time**

**Senior Engineers:**
- Architecture review (2 weeks)
- Performance analysis (1 week)
- Code review (ongoing)
- **Total: 3 weeks**

**DBA:**
- Database optimization (1 week)
- **Total: 1 week part-time**

**Total Human Effort:** ~20-25 person-weeks

---

#### Phase 6: Final Polish (1 month)
**Agentic Engineers:**
- Dev/prod parity (1 week)
- Admin process separation (1 week)
- Documentation (1 week)
- **Total: 3 weeks full-time**

**QA Engineers:**
- Final validation (1 week)
- **Total: 1 week part-time**

**Total Human Effort:** ~3.5 person-weeks

---

### Total Human Effort Summary

| Phase | Duration | Agentic Engineers | DevOps | QA | Senior | DBA | Total Person-Weeks |
|-------|----------|-------------------|--------|----|--------|-----|-------------------|
| Phase 0 | 2-4 weeks | 2-3 weeks | 1 week | 1 week | - | - | 4-5 weeks |
| Phase 1 | 1-2 weeks | 1.5-2 weeks | 1 day | 3 days | - | - | 2-3 weeks |
| Phase 2 | 1-2 months | 4-5 weeks | 3 days | 1 week | 1 week | - | 6-7 weeks |
| Phase 3 | 1 month | 3 weeks | - | 1 week | - | - | 3.5 weeks |
| Phase 4 | 1-2 months | 2 weeks | 4 weeks | 1 week | - | - | 7 weeks |
| Phase 5 | 3-6 months | 11-16 weeks | 2 weeks | 4 weeks | 3 weeks | 1 week | 20-25 weeks |
| Phase 6 | 1 month | 3 weeks | - | 1 week | - | - | 3.5 weeks |
| **Total** | **7-13 months** | **26-33 weeks** | **7-8 weeks** | **10-11 weeks** | **4 weeks** | **1 week** | **46-54 person-weeks** |

**Note:** Effort assumes recommended team size. Actual effort may vary based on team experience, codebase complexity, and external dependencies.

---

## Timeline Summary

| Phase | Duration | Priority | Status | Human Effort |
|-------|----------|----------|--------|--------------|
| Phase 0: Test Harness | 2-4 weeks | **CRITICAL** | Not Started | 4-5 person-weeks |
| Phase 1: Quick Wins | 1-2 weeks | High | Not Started | 2-3 person-weeks |
| Phase 2: Configuration | 1-2 months | Critical | Not Started | 6-7 person-weeks |
| Phase 3: Logging | 1 month | High | Not Started | 3.5 person-weeks |
| Phase 4: Containerization | 1-2 months | High | Not Started | 7 person-weeks |
| Phase 5: Stateless Design | 3-6 months | Critical | Not Started | 20-25 person-weeks |
| Phase 6: Final Polish | 1 month | Medium | Not Started | 3.5 person-weeks |
| **Total** | **7-13 months** | | | **46-54 person-weeks** |

---

## Next Steps

1. **Review and Approve Plan**
   - Stakeholder review
   - Resource allocation
   - Timeline confirmation

2. **Begin Phase 1**
   - Set up project tracking
   - Assign tasks
   - Start implementation

3. **Establish Metrics**
   - Define success metrics
   - Set up monitoring
   - Track progress

---

## Agentic Engineering Best Practices

### Code Search Strategy
1. **Start Broad:** Use `codebase_search` with semantic queries
2. **Narrow Down:** Use `grep` for specific patterns
3. **Read Context:** Read full files to understand implementation
4. **Verify Assumptions:** Test changes before committing

### Change Management
1. **Small Changes:** Make focused, testable changes
2. **Test First:** Write tests before/alongside changes
3. **Document:** Update docs with each change
4. **Review:** Code review before merging

### Error Handling
1. **Fail Fast:** Validate early, fail with clear errors
2. **Backward Compatible:** Maintain compatibility during transition
3. **Graceful Degradation:** Support both old and new mechanisms

---

## References

- **Twelve-Factor App:** https://www.12factor.net/
- **Analysis Documents:** `12-factor/` directory
- **Application Code:** `git/idempiere-2025-11-08/`
- **Maven/Tycho:** https://www.eclipse.org/tycho/
- **OSGi:** https://www.osgi.org/
- **Docker:** https://www.docker.com/
- **Kubernetes:** https://kubernetes.io/

---

**Document Version:** 1.0  
**Created:** 2025-01-27  
**Last Updated:** 2025-01-27  
**Next Review:** After Phase 1 completion

