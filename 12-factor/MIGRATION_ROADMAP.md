# Twelve-Factor Migration Roadmap

This document outlines a phased approach to migrate iDempiere to full twelve-factor compliance.

## Migration Phases Overview

```
Phase 0: Assessment          [COMPLETE]
Phase 1: Quick Wins          [1-2 weeks]
Phase 2: Configuration       [1-2 months]
Phase 3: Logging             [1 month]
Phase 4: Containerization   [1-2 months]
Phase 5: Stateless Design    [3-6 months]
Phase 6: Final Polish        [1 month]
```

---

## Phase 0: Assessment ✅

**Status:** Complete  
**Duration:** N/A

- ✅ Twelve-factor analysis completed
- ✅ Critical issues identified
- ✅ Migration roadmap created

---

## Phase 1: Quick Wins

**Status:** Not Started  
**Duration:** 1-2 weeks  
**Priority:** High  
**Effort:** Low

### Goals
- Implement low-effort improvements
- Establish foundation for further work
- Demonstrate quick value

### Tasks

#### 1.1 Port Configuration
- [ ] Make port configurable via `PORT` environment variable
- [ ] Default to 8080 if not set
- [ ] Update Jetty configuration to use `PORT` env var
- [ ] Test port configuration

**Files to Modify:**
- `org.adempiere.server-feature/idempiere-server.sh`
- Jetty configuration files

**Acceptance Criteria:**
- Application starts on port specified by `PORT` env var
- Defaults to 8080 if not set
- Works in containerized environment

#### 1.2 Health Check Endpoints
- [ ] Add `/health` endpoint for liveness probe
- [ ] Add `/health/ready` endpoint for readiness probe
- [ ] Add `/health/startup` endpoint for startup probe
- [ ] Return appropriate HTTP status codes

**Files to Create/Modify:**
- New servlet for health checks
- Register in OSGi service registry

**Acceptance Criteria:**
- `/health` returns 200 if process is running
- `/health/ready` returns 200 when ready to accept requests
- `/health/startup` returns 200 when startup complete
- Endpoints respond quickly (< 1 second)

#### 1.3 Startup Optimization
- [ ] Reduce cluster service wait time (from 180s to 30s)
- [ ] Make cluster service optional for single-instance deployments
- [ ] Add configuration to disable cluster wait

**Files to Modify:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java`

**Acceptance Criteria:**
- Startup completes in < 60 seconds for single instance
- Cluster wait can be disabled via configuration
- Application works without cluster service

#### 1.4 Logging Redirect (Partial)
- [ ] Add stdout logging alongside file logging
- [ ] Make file logging optional
- [ ] Support both logging mechanisms simultaneously

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/CLogFile.java`
- Logging configuration

**Acceptance Criteria:**
- Logs appear in both files and stdout
- File logging can be disabled
- No breaking changes to existing functionality

### Success Metrics
- Port configurable via environment variable
- Health check endpoints functional
- Startup time reduced to < 60 seconds
- Logs visible in stdout

---

## Phase 2: Configuration Refactoring

**Status:** Not Started  
**Duration:** 1-2 months  
**Priority:** Critical  
**Effort:** High

### Goals
- Move all configuration to environment variables
- Remove file system dependencies for configuration
- Support cloud-native configuration management

### Tasks

#### 2.1 Environment Variable Support
- [ ] Refactor `Ini.java` to read from environment variables first
- [ ] Support environment variable naming convention (`IDEMPIERE_*`)
- [ ] Maintain backward compatibility with properties file
- [ ] Document all configuration options

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/Ini.java`
- `org.adempiere.base/src/org/compiere/util/Env.java`

**Environment Variables to Support:**
```bash
# Database
IDEMPIERE_DB_TYPE
IDEMPIERE_DB_HOST
IDEMPIERE_DB_PORT
IDEMPIERE_DB_NAME
IDEMPIERE_DB_USER
IDEMPIERE_DB_PASSWORD
IDEMPIERE_DB_URL  # Alternative: full connection string

# Application
IDEMPIERE_HOME
IDEMPIERE_PORT
IDEMPIERE_TRACE_LEVEL
IDEMPIERE_TRACE_FILE
IDEMPIERE_LANGUAGE

# Clustering
IDEMPIERE_CLUSTER_ENABLED
IDEMPIERE_CLUSTER_WAIT_SECONDS
IDEMPIERE_CLUSTER_MAX_WAIT_SECONDS

# Security
IDEMPIERE_APPLICATION_USER_ID
IDEMPIERE_APPLICATION_PASSWORD
IDEMPIERE_STORE_PASSWORD
```

**Acceptance Criteria:**
- All configuration can be set via environment variables
- Properties file still works for backward compatibility
- Environment variables take precedence
- Configuration validation at startup
- Clear error messages for missing required config

#### 2.2 Secrets Management
- [ ] Support reading secrets from environment variables
- [ ] Remove password storage in properties file
- [ ] Support cloud secrets managers (future: AWS Secrets Manager, etc.)

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/SecureEngine.java`
- Configuration loading code

**Acceptance Criteria:**
- Passwords not stored in properties file
- Secrets can be provided via environment variables
- No sensitive data in configuration files

#### 2.3 Configuration Validation
- [ ] Validate all required configuration at startup
- [ ] Provide clear error messages for missing/invalid config
- [ ] Fail fast if critical configuration is missing

**Files to Create/Modify:**
- New configuration validator
- Startup code

**Acceptance Criteria:**
- Application fails to start with clear error if required config missing
- All configuration validated before use
- Error messages indicate which configuration is missing

### Success Metrics
- 100% of configuration available via environment variables
- No file system dependencies for configuration
- Configuration validation working
- Backward compatibility maintained

---

## Phase 3: Logging Refactoring

**Status:** Not Started  
**Duration:** 1 month  
**Priority:** High  
**Effort:** Medium

### Goals
- Redirect all logs to stdout/stderr
- Remove file system dependencies for logging
- Support structured logging

### Tasks

#### 3.1 Stdout/Stderr Logging
- [ ] Redirect all logs to stdout
- [ ] Redirect errors to stderr
- [ ] Make file logging optional (disabled by default)
- [ ] Remove log file dependencies

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/CLogFile.java`
- All logging code

**Acceptance Criteria:**
- All logs go to stdout
- All errors go to stderr
- File logging can be enabled via configuration
- No file system dependencies for logging

#### 3.2 Structured Logging
- [ ] Implement JSON log format option
- [ ] Add correlation IDs to logs
- [ ] Include standard fields (timestamp, level, message, etc.)

**Files to Modify:**
- Logging formatter
- Logging configuration

**Acceptance Criteria:**
- JSON log format available
- Correlation IDs in logs
- Standard log fields included
- Logs parseable by log aggregation tools

#### 3.3 Remove Log File Access
- [ ] Remove web interface log file access
- [ ] Replace with log streaming endpoint
- [ ] Support log aggregation services

**Files to Modify:**
- `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java`

**Acceptance Criteria:**
- No file system access for logs
- Log streaming endpoint available
- Compatible with cloud log aggregation

### Success Metrics
- All logs to stdout/stderr
- No file logging by default
- Structured logging available
- Log aggregation compatible

---

## Phase 4: Containerization

**Status:** Not Started  
**Duration:** 1-2 months  
**Priority:** High  
**Effort:** Medium

### Goals
- Create Docker images
- Separate build, release, run stages
- Support Kubernetes deployment

### Tasks

#### 4.1 Dockerfile Creation
- [ ] Create multi-stage Dockerfile
- [ ] Build stage: Compile OSGi bundles
- [ ] Release stage: Create immutable image
- [ ] Run stage: Start application

**Files to Create:**
- `Dockerfile`
- `.dockerignore`
- Docker build scripts

**Dockerfile Structure:**
```dockerfile
# Build stage
FROM maven:3.8-openjdk-17 AS build
WORKDIR /build
COPY . .
RUN mvn clean package

# Release stage
FROM eclipse-temurin:17-jre
WORKDIR /opt/idempiere
COPY --from=build /build/org.adempiere.server-feature/target/... ./plugins/
COPY --from=build /build/org.adempiere.server-feature/jettyhome ./jettyhome/
ENV PORT=8080
EXPOSE ${PORT}
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:${PORT}/health || exit 1
CMD ["java", "-jar", "plugins/org.eclipse.equinox.launcher_*.jar", \
     "-application", "org.adempiere.server.application"]
```

**Acceptance Criteria:**
- Docker image builds successfully
- Image is immutable (no runtime changes)
- Configuration via environment variables
- Health checks working

#### 4.2 Build/Release/Run Separation
- [ ] Build: Maven/Tycho creates OSGi bundles
- [ ] Release: Docker image with all bundles
- [ ] Run: Container starts with env vars

**Files to Create/Modify:**
- CI/CD pipeline
- Build scripts
- Release scripts

**Acceptance Criteria:**
- Clear separation of stages
- Immutable release artifacts
- No configuration in image
- Environment-specific config at runtime

#### 4.3 Kubernetes Manifests
- [ ] Create Deployment manifest
- [ ] Create Service manifest
- [ ] Create ConfigMap template
- [ ] Create Secrets template
- [ ] Create Ingress manifest (optional)

**Files to Create:**
- `k8s/deployment.yaml`
- `k8s/service.yaml`
- `k8s/configmap.yaml`
- `k8s/secrets.yaml`
- `k8s/ingress.yaml`

**Acceptance Criteria:**
- Kubernetes deployment works
- Configuration via ConfigMap/Secrets
- Service exposes application
- Health checks configured

### Success Metrics
- Docker image builds and runs
- Kubernetes deployment successful
- Configuration via environment variables
- Health checks working

---

## Phase 5: Stateless Design

**Status:** Not Started  
**Duration:** 3-6 months  
**Priority:** Critical  
**Effort:** Very High

### Goals
- Externalize all state
- Enable horizontal scaling
- Remove session affinity requirements

### Tasks

#### 5.1 Session State Externalization
- [ ] Move sessions to Redis or database
- [ ] Remove in-memory session storage
- [ ] Implement stateless session management

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/model/MSession.java`
- `org.adempiere.base/src/org/compiere/util/Env.java`
- Session management code

**Acceptance Criteria:**
- Sessions stored externally (Redis/database)
- No in-memory session storage
- Sessions accessible from any instance
- Session cleanup working

#### 5.2 Context Externalization
- [ ] Remove thread-local context storage
- [ ] Pass context via request parameters/headers
- [ ] Stateless request processing

**Files to Modify:**
- `org.adempiere.base/src/org/compiere/util/Env.java`
- `ServerContext` implementation
- All code using context

**Acceptance Criteria:**
- No thread-local context
- Context passed via request
- Stateless request processing
- Multiple instances work identically

#### 5.3 Cache Externalization
- [ ] Move caches to Redis
- [ ] Remove in-memory caches
- [ ] Shared cache across instances

**Files to Modify:**
- Cache implementation
- Cache usage throughout codebase

**Acceptance Criteria:**
- All caches external (Redis)
- No in-memory caches
- Cache shared across instances
- Cache invalidation working

#### 5.4 Stateless Authentication
- [ ] Implement JWT tokens
- [ ] Remove session-based authentication
- [ ] Stateless authorization

**Files to Modify:**
- Authentication code
- Authorization code
- Session management

**Acceptance Criteria:**
- JWT-based authentication
- No session-based auth
- Stateless authorization
- Token validation working

### Success Metrics
- No in-memory state
- Horizontal scaling works
- No session affinity required
- Multiple instances behind load balancer

---

## Phase 6: Final Polish

**Status:** Not Started  
**Duration:** 1 month  
**Priority:** Medium  
**Effort:** Low-Medium

### Goals
- Complete dev/prod parity
- Optimize admin processes
- Final testing and documentation

### Tasks

#### 6.1 Dev/Prod Parity
- [ ] Unify configuration mechanisms
- [ ] Containerize development environment
- [ ] Same setup process for all environments

**Files to Modify:**
- Development setup scripts
- Configuration code
- Documentation

**Acceptance Criteria:**
- Same configuration in dev and prod
- Development uses containers
- Same setup process

#### 6.2 Admin Process Separation
- [ ] Make all admin tasks independent
- [ ] Create separate containers for migrations
- [ ] Document admin process execution

**Files to Modify:**
- Migration scripts
- Setup scripts
- Documentation

**Acceptance Criteria:**
- All admin tasks independent
- Can run in separate containers
- Well documented

#### 6.3 Documentation
- [ ] Update deployment documentation
- [ ] Document environment variables
- [ ] Document migration process
- [ ] Create runbooks

**Files to Create:**
- Deployment guide
- Environment variable reference
- Migration guide
- Runbooks

**Acceptance Criteria:**
- Complete documentation
- Clear instructions
- Examples provided

### Success Metrics
- Dev/prod parity achieved
- Admin processes independent
- Complete documentation
- All twelve factors compliant

---

## Risk Mitigation

### Technical Risks

1. **Breaking Changes**
   - **Risk:** Refactoring may break existing functionality
   - **Mitigation:** Comprehensive testing, backward compatibility where possible

2. **Performance Impact**
   - **Risk:** External state may impact performance
   - **Mitigation:** Performance testing, caching strategies, optimization

3. **Migration Complexity**
   - **Risk:** Large codebase makes migration complex
   - **Mitigation:** Phased approach, incremental changes, thorough testing

### Business Risks

1. **Downtime**
   - **Risk:** Migration may require downtime
   - **Mitigation:** Blue-green deployments, gradual rollout

2. **Resource Requirements**
   - **Risk:** Migration requires significant resources
   - **Mitigation:** Phased approach, prioritize critical factors

3. **User Impact**
   - **Risk:** Changes may impact users
   - **Mitigation:** Backward compatibility, gradual rollout, user communication

---

## Success Criteria

### Phase Completion Criteria

Each phase is considered complete when:
- All tasks completed
- Acceptance criteria met
- Tests passing
- Documentation updated
- Code reviewed and approved

### Overall Success Criteria

Migration is successful when:
- ✅ All 12 factors compliant
- ✅ Application runs in cloud environment
- ✅ Horizontal scaling works
- ✅ No file system dependencies
- ✅ Configuration via environment variables
- ✅ Logs to stdout/stderr
- ✅ Health checks working
- ✅ Documentation complete

---

## Timeline Summary

| Phase | Duration | Start | End |
|-------|----------|-------|-----|
| Phase 1: Quick Wins | 1-2 weeks | TBD | TBD |
| Phase 2: Configuration | 1-2 months | TBD | TBD |
| Phase 3: Logging | 1 month | TBD | TBD |
| Phase 4: Containerization | 1-2 months | TBD | TBD |
| Phase 5: Stateless Design | 3-6 months | TBD | TBD |
| Phase 6: Final Polish | 1 month | TBD | TBD |
| **Total** | **6-12 months** | | |

---

## Next Steps

1. **Review and Approve Roadmap**
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

