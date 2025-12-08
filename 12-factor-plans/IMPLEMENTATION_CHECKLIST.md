# Twelve-Factor Implementation Checklist

**Target Application:** iDempiere ERP/CRM/SCM System  
**Location:** `git/idempiere-2025-11-08/`  
**For:** Agentic Engineers using Cursor

Use this checklist to track progress through the twelve-factor migration.

**⚠️ CRITICAL: Phase 0 (Test Harness Setup) MUST be completed before any application changes begin.**

---

## Phase 0: Test Harness Setup (2-4 weeks) ⚠️ CRITICAL PREREQUISITE

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete  
**Priority:** **CRITICAL - BLOCKER FOR ALL OTHER PHASES**

### 0.1 Enable Existing Test Suite
- [ ] Review existing test infrastructure in `org.idempiere.test/`
- [ ] Set `<skipTests>false</skipTests>` in `org.idempiere.test/pom.xml`
- [ ] Verify test dependencies are available
- [ ] Set up test database instance
- [ ] Run database migrations for test schema
- [ ] Seed test data (GardenWorld demo data)
- [ ] Execute test suite: `mvn test -pl org.idempiere.test`
- [ ] Document test results and failures
- [ ] Fix environment/setup issues
- [ ] Establish baseline: "X tests passing, Y tests failing"
- [ ] Document test execution process
- [ ] Document test database setup

**Files:**
- `org.idempiere.test/pom.xml`
- Test database setup scripts

---

### 0.2 CI/CD Pipeline for Tests
- [ ] Choose CI/CD platform (GitHub Actions, GitLab CI, Jenkins)
- [ ] Create CI/CD configuration file
- [ ] Set up test database in CI environment
- [ ] Configure test execution on every commit
- [ ] Configure test execution on pull requests
- [ ] Set up test result reporting
- [ ] Create `scripts/run-tests.sh`
- [ ] Create `scripts/setup-test-db.sh`
- [ ] Configure JUnit XML reports
- [ ] Configure test coverage reports (JaCoCo)
- [ ] Set up test result notifications
- [ ] Configure Docker Compose for test database
- [ ] Test CI/CD pipeline execution
- [ ] Verify test failures block merges (configurable)
- [ ] Verify test execution time < 30 minutes

**Files:**
- `.github/workflows/test.yml` (or equivalent)
- `scripts/run-tests.sh` (new)
- `scripts/setup-test-db.sh` (new)

---

### 0.3 Test Coverage Baseline
- [ ] Set up JaCoCo or similar coverage tool
- [ ] Configure coverage thresholds
- [ ] Run coverage analysis on existing code
- [ ] Document coverage by module/package
- [ ] Identify gaps in test coverage
- [ ] Set coverage goals for migration
- [ ] Create coverage dashboard
- [ ] Configure coverage tracking in CI/CD
- [ ] Generate baseline coverage report
- [ ] Document coverage baseline

**Files:**
- Coverage configuration
- `docs/TEST_COVERAGE_BASELINE.md` (new)

---

### 0.4 Integration Test Framework
- [ ] Create `org.idempiere.test.integration/` module
- [ ] Configure Maven module for integration tests
- [ ] Create `ConfigTestHelper` utility
- [ ] Create `HealthCheckTestHelper` utility
- [ ] Create `LoggingTestHelper` utility
- [ ] Create `ContainerTestHelper` utility
- [ ] Create base integration test class
- [ ] Create sample integration test for env vars
- [ ] Create sample integration test for health checks
- [ ] Create sample integration test for logging
- [ ] Create sample integration test for containers
- [ ] Verify integration tests can run independently
- [ ] Document integration test framework

**Files:**
- `org.idempiere.test.integration/` (new module)
- Integration test utilities (new)

---

### 0.5 Test Data Management
- [ ] Create `test-data/` directory structure
- [ ] Organize test data by test type
- [ ] Create test data fixtures
- [ ] Create test data seeding scripts
- [ ] Create test data reset scripts
- [ ] Create test data cleanup scripts
- [ ] Verify test data isolation between tests
- [ ] Document test data requirements
- [ ] Document test data management process

**Files:**
- `test-data/` directory (new)
- Test data scripts (new)

---

### Phase 0 Completion Validation
- [ ] All existing tests can be executed
- [ ] CI/CD pipeline runs tests automatically
- [ ] Test coverage baseline established
- [ ] Integration test framework ready
- [ ] Test data management in place
- [ ] All Phase 0 acceptance criteria met
- [ ] Team trained on test execution
- [ ] Documentation complete
- [ ] **Phase 0 sign-off obtained before Phase 1 begins**

---

## Phase 1: Quick Wins (1-2 weeks)

### 1.1 Port Configuration
- [ ] Search codebase for port configuration
- [ ] Modify `idempiere-server.sh` to read `PORT` env var
- [ ] Update Jetty configuration to use `PORT`
- [ ] Test with custom port: `PORT=9090 ./idempiere-server.sh`
- [ ] Verify application accessible on custom port
- [ ] Document port configuration

**Files:**
- `org.adempiere.server-feature/idempiere-server.sh`
- Jetty config files in `org.adempiere.server-feature/jettyhome/etc/`

---

### 1.2 Health Check Endpoints
- [ ] Create `HealthCheckServlet.java`
- [ ] Implement `/health` endpoint (liveness)
- [ ] Implement `/health/ready` endpoint (readiness)
- [ ] Implement `/health/startup` endpoint (startup)
- [ ] Register servlet in OSGi service registry
- [ ] Test endpoints: `curl http://localhost:8080/health`
- [ ] Verify endpoints respond quickly (< 1 second)
- [ ] Document health check endpoints

**Files:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/HealthCheckServlet.java` (new)
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java` (modify)

---

### 1.3 Startup Optimization
- [ ] Add `IDEMPIERE_CLUSTER_ENABLED` env var support
- [ ] Reduce cluster wait times (10s → 5s initial, 180s → 30s max)
- [ ] Skip cluster wait if `IDEMPIERE_CLUSTER_ENABLED=false`
- [ ] Test startup with cluster disabled
- [ ] Verify startup time < 60 seconds
- [ ] Test backward compatibility (cluster still works if enabled)
- [ ] Document cluster configuration

**Files:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java` (lines 1396-1439)

---

### 1.4 Logging Redirect (Partial)
- [ ] Search codebase for logging implementation
- [ ] Add stdout handler to logging configuration
- [ ] Add `IDEMPIERE_LOG_TO_FILE` env var support
- [ ] Test with file logging disabled: `IDEMPIERE_LOG_TO_FILE=false`
- [ ] Verify logs appear in stdout
- [ ] Verify backward compatibility (file logging still works)
- [ ] Document logging configuration

**Files:**
- `org.adempiere.base/src/org/compiere/util/CLogFile.java`

---

## Phase 2: Configuration Refactoring (1-2 months)

### 2.1 Environment Variable Support
- [ ] Review `Ini.java` implementation
- [ ] Create environment variable mapper
- [ ] Modify `getProperty()` to check env vars first
- [ ] Support `IDEMPIERE_DB_TYPE` env var
- [ ] Support `IDEMPIERE_DB_HOST` env var
- [ ] Support `IDEMPIERE_DB_PORT` env var
- [ ] Support `IDEMPIERE_DB_NAME` env var
- [ ] Support `IDEMPIERE_DB_USER` env var
- [ ] Support `IDEMPIERE_DB_PASSWORD` env var
- [ ] Support `IDEMPIERE_DB_URL` (alternative format)
- [ ] Support `IDEMPIERE_HOME` env var
- [ ] Support `IDEMPIERE_PORT` env var
- [ ] Support `IDEMPIERE_TRACE_LEVEL` env var
- [ ] Support `IDEMPIERE_LANGUAGE` env var
- [ ] Support `IDEMPIERE_CLUSTER_ENABLED` env var
- [ ] Support `IDEMPIERE_CLUSTER_WAIT_SECONDS` env var
- [ ] Support `IDEMPIERE_CLUSTER_MAX_WAIT_SECONDS` env var
- [ ] Support `IDEMPIERE_APPLICATION_USER_ID` env var
- [ ] Support `IDEMPIERE_APPLICATION_PASSWORD` env var
- [ ] Test all env vars take precedence over file
- [ ] Test backward compatibility (file still works)
- [ ] Document all environment variables

**Files:**
- `org.adempiere.base/src/org/compiere/util/Ini.java`
- `org.adempiere.base/src/org/compiere/util/Env.java`

---

### 2.2 Secrets Management
- [ ] Identify password storage locations
- [ ] Require passwords via environment variables
- [ ] Support `IDEMPIERE_DB_PASSWORD_FILE` (read from file)
- [ ] Fail startup if passwords in properties file
- [ ] Test with password from env var
- [ ] Test with password from file
- [ ] Verify no passwords in properties file
- [ ] Document secrets management

**Files:**
- `org.adempiere.base/src/org/compiere/util/SecureEngine.java`
- Configuration loading code

---

### 2.3 Configuration Validation
- [ ] Create `ConfigValidator.java`
- [ ] Validate required configuration at startup
- [ ] Check database connection parameters
- [ ] Provide clear error messages for missing config
- [ ] Fail fast with helpful errors
- [ ] Test with missing required config
- [ ] Test with all required config present
- [ ] Document configuration requirements

**Files:**
- `org.adempiere.base/src/org/compiere/util/ConfigValidator.java` (new)

---

## Phase 3: Logging Refactoring (1 month)

### 3.1 Stdout/Stderr Logging
- [ ] Review `CLogFile.java` implementation
- [ ] Replace file handler with console handler
- [ ] Redirect all logs to stdout
- [ ] Redirect errors to stderr
- [ ] Make file logging optional (disabled by default)
- [ ] Remove file system dependencies
- [ ] Test logs appear in stdout
- [ ] Test errors appear in stderr
- [ ] Test file logging can be enabled
- [ ] Document logging configuration

**Files:**
- `org.adempiere.base/src/org/compiere/util/CLogFile.java`

---

### 3.2 Structured Logging
- [ ] Create JSON log formatter
- [ ] Add standard fields (timestamp, level, message)
- [ ] Add correlation IDs
- [ ] Support `IDEMPIERE_LOG_FORMAT=json` env var
- [ ] Test JSON log format
- [ ] Test text log format (backward compatibility)
- [ ] Verify logs parseable by log aggregation tools
- [ ] Document log formats

**Files:**
- Logging formatter
- Logging configuration

---

### 3.3 Remove Log File Access
- [ ] Review `AdempiereMonitor.java` log file access
- [ ] Remove file-based log reading
- [ ] Create log streaming endpoint
- [ ] Update web interface to use streaming
- [ ] Test log streaming endpoint
- [ ] Verify no file system access for logs
- [ ] Document log streaming

**Files:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java`

---

## Phase 4: Containerization (1-2 months)

### 4.1 Dockerfile Creation
- [ ] Create multi-stage `Dockerfile`
- [ ] Create `.dockerignore`
- [ ] Build stage: Compile OSGi bundles
- [ ] Release stage: Create immutable image
- [ ] Configure environment variables
- [ ] Add health check
- [ ] Test Docker build: `docker build -t idempiere:latest .`
- [ ] Test Docker run with env vars
- [ ] Verify image is immutable
- [ ] Optimize image size
- [ ] Document Docker usage

**Files:**
- `Dockerfile` (new)
- `.dockerignore` (new)

---

### 4.2 Build/Release/Run Separation
- [ ] Create `scripts/build.sh`
- [ ] Create `scripts/release.sh`
- [ ] Build stage: Maven creates bundles
- [ ] Release stage: Docker image creation
- [ ] Run stage: Container with env vars
- [ ] Test build script
- [ ] Test release script
- [ ] Verify clear separation of stages
- [ ] Document build/release/run process

**Files:**
- `scripts/build.sh` (new)
- `scripts/release.sh` (new)

---

### 4.3 Kubernetes Manifests
- [ ] Create `k8s/deployment.yaml`
- [ ] Create `k8s/service.yaml`
- [ ] Create `k8s/configmap.yaml`
- [ ] Create `k8s/secrets.yaml`
- [ ] Create `k8s/ingress.yaml` (optional)
- [ ] Configure health checks in deployment
- [ ] Configure environment variables
- [ ] Test Kubernetes deployment
- [ ] Verify configuration via ConfigMap/Secrets
- [ ] Document Kubernetes deployment

**Files:**
- `k8s/deployment.yaml` (new)
- `k8s/service.yaml` (new)
- `k8s/configmap.yaml` (new)
- `k8s/secrets.yaml` (new)
- `k8s/ingress.yaml` (new, optional)

---

## Phase 5: Stateless Design (3-6 months)

### 5.1 Session State Externalization
- [ ] Review `MSession.java` implementation
- [ ] Identify all session storage locations
- [ ] Choose external store (database or Redis)
- [ ] Remove in-memory session storage
- [ ] Store all sessions in external store
- [ ] Implement session retrieval by ID
- [ ] Update all session access code
- [ ] Test sessions accessible from any instance
- [ ] Test session cleanup
- [ ] Performance test session externalization
- [ ] Document session management

**Files:**
- `org.adempiere.base/src/org/compiere/model/MSession.java`
- `org.adempiere.base/src/org/compiere/util/Env.java`
- Session management code

---

### 5.2 Context Externalization
- [ ] Review `ServerContext` implementation
- [ ] Identify all context usage patterns
- [ ] Remove thread-local context storage
- [ ] Pass context via request headers/parameters
- [ ] Update all `Env.getCtx()` usage
- [ ] Implement stateless request processing
- [ ] Test multiple instances work identically
- [ ] Test no session affinity required
- [ ] Performance test context externalization
- [ ] Document context management

**Files:**
- `org.adempiere.base/src/org/compiere/util/Env.java`
- `ServerContext` implementation
- All code using context

---

### 5.3 Cache Externalization
- [ ] Search codebase for cache implementations
- [ ] List all in-memory caches
- [ ] Add Redis client dependency
- [ ] Create Redis cache implementation
- [ ] Replace in-memory caches with Redis
- [ ] Update all cache access code
- [ ] Test cache shared across instances
- [ ] Test cache invalidation
- [ ] Performance test cache externalization
- [ ] Document cache management

**Files:**
- Cache implementation files
- Cache usage throughout codebase

---

### 5.4 Stateless Authentication
- [ ] Review authentication implementation
- [ ] Add JWT library dependency
- [ ] Create token generation
- [ ] Create token validation
- [ ] Replace session-based auth with JWT
- [ ] Update authentication code
- [ ] Update authorization code
- [ ] Test JWT authentication
- [ ] Test token expiration
- [ ] Test stateless authorization
- [ ] Document authentication

**Files:**
- Authentication code
- Authorization code
- Session management

---

## Phase 6: Final Polish (1 month)

### 6.1 Dev/Prod Parity
- [ ] Review dev-specific configuration
- [ ] Unify configuration mechanisms
- [ ] Remove dev-specific files
- [ ] Containerize development environment
- [ ] Use same Docker image for dev/prod
- [ ] Test development in containers
- [ ] Test production deployment
- [ ] Verify same setup process
- [ ] Document dev/prod parity

**Files:**
- Development setup scripts
- Configuration code
- Documentation

---

### 6.2 Admin Process Separation
- [ ] Review migration scripts
- [ ] Make migrations independent
- [ ] Remove application context requirements
- [ ] Create separate Docker images for migrations
- [ ] Create Kubernetes Jobs for migrations
- [ ] Test migrations in separate containers
- [ ] Document admin processes
- [ ] Create runbooks

**Files:**
- Migration scripts
- Setup scripts
- Documentation

---

### 6.3 Documentation
- [ ] Create `DEPLOYMENT.md`
- [ ] Create `ENVIRONMENT_VARIABLES.md`
- [ ] Create `MIGRATION_GUIDE.md`
- [ ] Create `RUNBOOKS.md`
- [ ] Update `README.md`
- [ ] Document all environment variables
- [ ] Document deployment process
- [ ] Document migration process
- [ ] Create examples
- [ ] Review and finalize documentation

**Files:**
- `DEPLOYMENT.md` (new)
- `ENVIRONMENT_VARIABLES.md` (new)
- `MIGRATION_GUIDE.md` (new)
- `RUNBOOKS.md` (new)

---

## Testing Checklist

### Unit Tests
- [ ] Test configuration loading from env vars
- [ ] Test environment variable precedence
- [ ] Test configuration validation
- [ ] Test session externalization
- [ ] Test context externalization
- [ ] Test stateless request processing

### Integration Tests
- [ ] Test database connection with env vars
- [ ] Test health check endpoints
- [ ] Test logging to stdout
- [ ] Test Docker image build
- [ ] Test Docker container run
- [ ] Test Kubernetes deployment

### End-to-End Tests
- [ ] Test full deployment in container
- [ ] Test Kubernetes deployment
- [ ] Test horizontal scaling (after Phase 5)
- [ ] Test load balancing (after Phase 5)
- [ ] Test zero-downtime deployment

### Performance Tests
- [ ] Benchmark session externalization
- [ ] Benchmark cache externalization
- [ ] Benchmark startup time
- [ ] Benchmark request processing
- [ ] Compare before/after performance

---

## Validation Checklist

### Factor I: Codebase
- [ ] Single codebase tracked in Git
- [ ] Multiple deploys from same codebase
- [ ] No environment-specific code

### Factor II: Dependencies
- [ ] Dependencies declared in POM files
- [ ] OSGi runtime requirements documented
- [ ] Container image includes all dependencies

### Factor III: Config
- [ ] All configuration via environment variables
- [ ] No configuration in code
- [ ] Secrets not in files
- [ ] Configuration validated at startup

### Factor IV: Backing Services
- [ ] Database treated as attached resource
- [ ] Connection via environment variables
- [ ] Service discovery supported (optional)

### Factor V: Build, Release, Run
- [ ] Build stage: Maven creates bundles
- [ ] Release stage: Docker image created
- [ ] Run stage: Container with env vars
- [ ] Clear separation of stages

### Factor VI: Processes
- [ ] Stateless processes
- [ ] No in-memory state
- [ ] Sessions externalized
- [ ] Horizontal scaling works

### Factor VII: Port Binding
- [ ] Application binds to port directly
- [ ] Port configurable via `PORT` env var
- [ ] Embedded Jetty server

### Factor VIII: Concurrency
- [ ] Process model supports concurrency
- [ ] Horizontal scaling enabled
- [ ] No stateful limitations

### Factor IX: Disposability
- [ ] Fast startup (< 60 seconds)
- [ ] Graceful shutdown
- [ ] Health checks working
- [ ] No startup dependencies

### Factor X: Dev/Prod Parity
- [ ] Same configuration mechanism
- [ ] Same Docker image
- [ ] Same setup process
- [ ] No environment differences

### Factor XI: Logs
- [ ] Logs to stdout
- [ ] Errors to stderr
- [ ] Structured logging (JSON) available
- [ ] No file system dependencies

### Factor XII: Admin Processes
- [ ] All admin tasks independent
- [ ] Can run in separate containers
- [ ] No application context required
- [ ] Well documented

---

## Progress Tracking

### Phase 0: Test Harness Setup ⚠️ CRITICAL
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________
- **Sign-off Date:** _______________
- **Notes:** Phase 0 MUST be complete before Phase 1 begins

### Phase 1: Quick Wins
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________
- **Prerequisite:** Phase 0 must be ✅ Complete

### Phase 2: Configuration
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________

### Phase 3: Logging
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________

### Phase 4: Containerization
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________

### Phase 5: Stateless Design
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________

### Phase 6: Final Polish
- **Status:** ⬜ Not Started / 🟡 In Progress / ✅ Complete
- **Completion:** ___%
- **Blockers:** ________________

---

## Notes

Use this section to track issues, decisions, and important information:

```
Date: ___________
Phase: ___________
Issue: ___________
Resolution: ___________

Date: ___________
Phase: ___________
Issue: ___________
Resolution: ___________
```

---

**Document Version:** 1.0  
**Created:** 2025-01-27  
**Last Updated:** 2025-01-27

