# Code Implementation Guide for Twelve-Factor Migration

**Target Application:** iDempiere ERP/CRM/SCM System  
**Location:** `git/idempiere-2025-11-08/`  
**For:** Agentic Engineers using Cursor

This document provides specific code examples, file locations, and implementation patterns for the twelve-factor migration.

---

## Table of Contents

1. [Test Harness Setup (Phase 0)](#test-harness-setup-phase-0)
2. [Configuration Management](#configuration-management)
3. [Health Check Implementation](#health-check-implementation)
4. [Logging Refactoring](#logging-refactoring)
5. [Session State Externalization](#session-state-externalization)
6. [Dockerfile Examples](#dockerfile-examples)
7. [Kubernetes Manifests](#kubernetes-manifests)

---

## Test Harness Setup (Phase 0)

**⚠️ CRITICAL: This phase MUST be completed before any application code changes.**

### Enable Existing Test Suite

**File to Modify:** `org.idempiere.test/pom.xml`

**Enable Test Execution:**
```xml
<properties>
    <idempiere.home>..</idempiere.home>
    <skipTests>false</skipTests>  <!-- Change from true to false -->
    <sonar.skip>true</sonar.skip>
    <!-- ... existing properties ... -->
</properties>
```

**Run Tests:**
```bash
# Run all tests
mvn test -pl org.idempiere.test

# Run specific test class
mvn test -pl org.idempiere.test -Dtest=SalesOrderTest

# Run with coverage
mvn test -pl org.idempiere.test jacoco:report
```

---

### CI/CD Pipeline Configuration

**File to Create:** `.github/workflows/test.yml`

```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: idempiere_test
          POSTGRES_USER: adempiere
          POSTGRES_PASSWORD: adempiere
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Cache Maven dependencies
      uses: actions/cache@v3
      with:
        path: ~/.m2
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
        restore-keys: ${{ runner.os }}-m2
    
    - name: Set up test database
      run: |
        # Run database migrations
        # Seed test data
        # Configure test environment
    
    - name: Run tests
      run: mvn test -pl org.idempiere.test
      env:
        IDEMPIERE_HOME: ${{ github.workspace }}
        IDEMPIERE_DB_HOST: localhost
        IDEMPIERE_DB_PORT: 5432
        IDEMPIERE_DB_NAME: idempiere_test
        IDEMPIERE_DB_USER: adempiere
        IDEMPIERE_DB_PASSWORD: adempiere
    
    - name: Generate test report
      if: always()
      uses: dorny/test-reporter@v1
      with:
        name: Test Results
        path: org.idempiere.test/target/surefire-reports/*.xml
        reporter: java-junit
    
    - name: Upload coverage reports
      if: always()
      uses: codecov/codecov-action@v3
      with:
        files: org.idempiere.test/target/site/jacoco/jacoco.xml
```

---

### Test Coverage Configuration

**File to Modify:** `org.idempiere.test/pom.xml`

**Add JaCoCo Plugin:**
```xml
<build>
    <plugins>
        <!-- ... existing plugins ... -->
        
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.10</version>
            <executions>
                <execution>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

---

### Integration Test Framework

**File to Create:** `org.idempiere.test.integration/src/org/idempiere/test/integration/ConfigTestHelper.java`

```java
package org.idempiere.test.integration;

import java.util.Map;
import java.util.HashMap;

/**
 * Helper utility for testing configuration changes
 */
public class ConfigTestHelper {
    
    private static Map<String, String> originalEnvVars = new HashMap<>();
    
    /**
     * Set environment variable for testing
     * Note: In real implementation, use reflection or test framework support
     */
    public static void setEnvVar(String key, String value) {
        originalEnvVars.put(key, System.getenv(key));
        // Set environment variable (implementation depends on test framework)
    }
    
    /**
     * Restore original environment variables
     */
    public static void restoreEnvVars() {
        originalEnvVars.forEach((key, value) -> {
            if (value == null) {
                // Remove env var
            } else {
                // Restore env var
            }
        });
        originalEnvVars.clear();
    }
    
    /**
     * Test configuration loading from environment variable
     */
    public static void testEnvVarConfig(String envVar, String expectedValue) {
        // Implementation for testing env var configuration
    }
}
```

**File to Create:** `org.idempiere.test.integration/src/org/idempiere/test/integration/HealthCheckTestHelper.java`

```java
package org.idempiere.test.integration;

import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Helper utility for testing health check endpoints
 */
public class HealthCheckTestHelper {
    
    /**
     * Test health check endpoint
     */
    public static boolean testHealthEndpoint(String baseUrl, String endpoint) {
        try {
            URL url = new URL(baseUrl + endpoint);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            
            int responseCode = conn.getResponseCode();
            return responseCode == 200;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Test liveness probe
     */
    public static boolean testLiveness(String baseUrl) {
        return testHealthEndpoint(baseUrl, "/health");
    }
    
    /**
     * Test readiness probe
     */
    public static boolean testReadiness(String baseUrl) {
        return testHealthEndpoint(baseUrl, "/health/ready");
    }
    
    /**
     * Test startup probe
     */
    public static boolean testStartup(String baseUrl) {
        return testHealthEndpoint(baseUrl, "/health/startup");
    }
}
```

---

### Test Data Management Scripts

**File to Create:** `scripts/setup-test-db.sh`

```bash
#!/bin/bash
# Setup test database for iDempiere tests

set -e

DB_HOST=${IDEMPIERE_DB_HOST:-localhost}
DB_PORT=${IDEMPIERE_DB_PORT:-5432}
DB_NAME=${IDEMPIERE_DB_NAME:-idempiere_test}
DB_USER=${IDEMPIERE_DB_USER:-adempiere}
DB_PASSWORD=${IDEMPIERE_DB_PASSWORD:-adempiere}

echo "Setting up test database: $DB_NAME"

# Create database if it doesn't exist
psql -h $DB_HOST -p $DB_PORT -U postgres -c "CREATE DATABASE $DB_NAME;" || true

# Run migrations
echo "Running database migrations..."
# Run migration scripts from db/postgresql/

# Seed test data
echo "Seeding test data..."
# Run GardenWorld seed data

echo "Test database setup complete"
```

**File to Create:** `scripts/reset-test-db.sh`

```bash
#!/bin/bash
# Reset test database to clean state

set -e

DB_HOST=${IDEMPIERE_DB_HOST:-localhost}
DB_PORT=${IDEMPIERE_DB_PORT:-5432}
DB_NAME=${IDEMPIERE_DB_NAME:-idempiere_test}

echo "Resetting test database: $DB_NAME"

# Drop and recreate database
psql -h $DB_HOST -p $DB_PORT -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -h $DB_HOST -p $DB_PORT -U postgres -c "CREATE DATABASE $DB_NAME;"

# Run setup script
./scripts/setup-test-db.sh

echo "Test database reset complete"
```

---

## Configuration Management

## Configuration Management

### Current Implementation

**File:** `org.adempiere.base/src/org/compiere/util/Ini.java`

**Key Methods:**
- `getFileName(boolean tryUserHome)` - Gets properties file path
- `loadProperties(String fileName)` - Loads properties from file
- `getProperty(String key)` - Gets property value

**Current Behavior:**
```java
// Current: Reads from idempiere.properties file
String fileName = getFileName(tryUserHome);
loadProperties(fileName);
String value = getProperty("Connection");
```

### Target Implementation

**Environment Variable Support Pattern:**
```java
/**
 * Get property value from environment variable or properties file
 * Priority: Environment Variable > Properties File > Default
 */
public static String getProperty(String key) {
    // 1. Check environment variable first
    String envKey = convertToEnvVarName(key);
    String envValue = System.getenv(envKey);
    if (envValue != null && !envValue.isEmpty()) {
        return envValue;
    }
    
    // 2. Fallback to properties file
    String fileValue = properties.getProperty(key);
    if (fileValue != null && !fileValue.isEmpty()) {
        return fileValue;
    }
    
    // 3. Return default or null
    return null;
}

/**
 * Convert property key to environment variable name
 * Example: "Connection" -> "IDEMPIERE_CONNECTION"
 * Example: "DBhost" -> "IDEMPIERE_DB_HOST"
 */
private static String convertToEnvVarName(String key) {
    // Handle special cases
    if (key.equals("Connection")) {
        // Connection is complex, handle separately
        return null; // Use specific DB env vars instead
    }
    
    // Convert camelCase/PascalCase to UPPER_SNAKE_CASE
    String envKey = key
        .replaceAll("([a-z])([A-Z])", "$1_$2")  // camelCase -> camel_Case
        .toUpperCase();                          // -> CAMEL_CASE
    
    return "IDEMPIERE_" + envKey;
}
```

### Database Connection Configuration

**Current Format:**
```properties
Connection=xyzCConnection[name=machineName{...},DBhost=databaseHost,DBport=databasePort,DBname=databaseName,UID=databaseLogin,PWD=databasePassword]
```

**Target: Environment Variables**
```java
/**
 * Build database connection from environment variables
 */
public static String buildDatabaseConnection() {
    String dbType = getEnvOrProperty("IDEMPIERE_DB_TYPE", "DB_TYPE", "postgresql");
    String dbHost = getEnvOrProperty("IDEMPIERE_DB_HOST", "DB_HOST", "localhost");
    String dbPort = getEnvOrProperty("IDEMPIERE_DB_PORT", "DB_PORT", "5432");
    String dbName = getEnvOrProperty("IDEMPIERE_DB_NAME", "DB_NAME", "idempiere");
    String dbUser = getEnvOrProperty("IDEMPIERE_DB_USER", "DB_USER", "adempiere");
    String dbPassword = getEnvOrProperty("IDEMPIERE_DB_PASSWORD", "DB_PASSWORD", null);
    
    if (dbPassword == null) {
        throw new IllegalStateException("IDEMPIERE_DB_PASSWORD is required");
    }
    
    // Build connection string in existing format
    return String.format(
        "xyzCConnection[name=%s{...},DBhost=%s,DBport=%s,DBname=%s,UID=%s,PWD=%s]",
        dbType, dbHost, dbPort, dbName, dbUser, dbPassword
    );
}

/**
 * Support DATABASE_URL format (common cloud convention)
 * Format: postgresql://user:password@host:port/dbname
 */
public static String parseDatabaseUrl(String databaseUrl) {
    if (databaseUrl == null || databaseUrl.isEmpty()) {
        return null;
    }
    
    try {
        URI uri = new URI(databaseUrl);
        String scheme = uri.getScheme(); // postgresql, oracle, etc.
        String userInfo = uri.getUserInfo();
        String host = uri.getHost();
        int port = uri.getPort();
        String path = uri.getPath().substring(1); // Remove leading /
        
        String[] userPass = userInfo.split(":");
        String user = userPass[0];
        String password = userPass.length > 1 ? userPass[1] : "";
        
        return buildDatabaseConnection(scheme, host, port, path, user, password);
    } catch (URISyntaxException e) {
        throw new IllegalArgumentException("Invalid DATABASE_URL format", e);
    }
}
```

### Configuration Validation

**File to Create:** `org.adempiere.base/src/org/compiere/util/ConfigValidator.java`

```java
package org.compiere.util;

import java.util.ArrayList;
import java.util.List;

/**
 * Validates required configuration at startup
 */
public class ConfigValidator {
    
    private static final List<String> REQUIRED_CONFIG = List.of(
        "IDEMPIERE_DB_HOST",
        "IDEMPIERE_DB_NAME",
        "IDEMPIERE_DB_USER",
        "IDEMPIERE_DB_PASSWORD"
    );
    
    /**
     * Validate all required configuration
     * @throws IllegalStateException if required config is missing
     */
    public static void validate() {
        List<String> missing = new ArrayList<>();
        
        for (String key : REQUIRED_CONFIG) {
            String value = System.getenv(key);
            if (value == null || value.isEmpty()) {
                // Check properties file as fallback
                value = Ini.getProperty(key.replace("IDEMPIERE_", ""));
                if (value == null || value.isEmpty()) {
                    missing.add(key);
                }
            }
        }
        
        if (!missing.isEmpty()) {
            throw new IllegalStateException(
                "Missing required configuration: " + String.join(", ", missing) +
                "\nPlease set these environment variables or configure in idempiere.properties"
            );
        }
    }
}
```

---

## Health Check Implementation

### Health Check Servlet

**File to Create:** `org.adempiere.server/src/main/servlet/org/compiere/web/HealthCheckServlet.java`

```java
package org.compiere.web;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.compiere.util.DB;
import org.compiere.util.Env;
import org.idempiere.hazelcast.service.ClusterServerMgr;

/**
 * Health check endpoints for Kubernetes/container orchestration
 */
public class HealthCheckServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String path = request.getPathInfo();
        
        if (path == null || path.equals("/")) {
            // Liveness probe: Is process running?
            liveness(response);
        } else if (path.equals("/ready")) {
            // Readiness probe: Ready to accept requests?
            readiness(response);
        } else if (path.equals("/startup")) {
            // Startup probe: Has startup completed?
            startup(response);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Liveness probe: Always returns 200 if servlet is accessible
     */
    private void liveness(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"alive\"}");
    }
    
    /**
     * Readiness probe: Checks if application is ready to accept requests
     */
    private void readiness(HttpServletResponse response) throws IOException {
        boolean ready = true;
        List<String> issues = new ArrayList<>();
        
        // Check database connection
        if (!DB.isConnected()) {
            ready = false;
            issues.add("database_not_connected");
        }
        
        // Check cluster service (if enabled)
        String clusterEnabled = System.getenv("IDEMPIERE_CLUSTER_ENABLED");
        if ("true".equalsIgnoreCase(clusterEnabled)) {
            if (ClusterServerMgr.getClusterService() == null) {
                ready = false;
                issues.add("cluster_service_not_ready");
            }
        }
        
        response.setContentType("application/json");
        if (ready) {
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"status\":\"ready\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write(
                "{\"status\":\"not_ready\",\"issues\":" + 
                new com.google.gson.Gson().toJson(issues) + "}"
            );
        }
    }
    
    /**
     * Startup probe: Checks if startup has completed
     */
    private void startup(HttpServletResponse response) throws IOException {
        // Check if initialization is complete
        // This could check a flag set during startup
        boolean started = isStartupComplete();
        
        response.setContentType("application/json");
        if (started) {
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"status\":\"started\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"status\":\"starting\"}");
        }
    }
    
    private boolean isStartupComplete() {
        // Implement logic to check if startup is complete
        // Could check a static flag, or database initialization, etc.
        return DB.isConnected(); // Simple check for now
    }
}
```

### Register Health Check Servlet

**File to Modify:** `org.adempiere.server/src/main/servlet/org/compiere/web/AdempiereMonitor.java`

**Add servlet registration:**
```java
// In init() method or servlet registration code
@Reference
private HttpService httpService;

public void init(ServletConfig config) throws ServletException {
    // ... existing init code ...
    
    // Register health check servlet
    try {
        Dictionary<String, Object> props = new Hashtable<>();
        props.put("alias", "/health");
        httpService.registerServlet("/health", new HealthCheckServlet(), props, null);
        log.info("Health check servlet registered at /health");
    } catch (Exception e) {
        log.warning("Failed to register health check servlet: " + e.getMessage());
    }
}
```

---

## Logging Refactoring

### Current Logging Implementation

**File:** `org.adempiere.base/src/org/compiere/util/CLogFile.java`

**Key Methods:**
- `get(boolean create, String fileName, boolean append)` - Gets log file handler
- `getLogDirectory()` - Gets log directory

### Target Implementation

**Add stdout/stderr logging:**
```java
package org.compiere.util;

import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.StreamHandler;

/**
 * Enhanced logging with stdout/stderr support
 */
public class CLogFile {
    
    private static boolean logToFile = true;
    private static boolean logToStdout = true;
    private static String logFormat = "text"; // "text" or "json"
    
    static {
        // Check environment variables
        String logToFileEnv = System.getenv("IDEMPIERE_LOG_TO_FILE");
        if ("false".equalsIgnoreCase(logToFileEnv)) {
            logToFile = false;
        }
        
        String logToStdoutEnv = System.getenv("IDEMPIERE_LOG_TO_STDOUT");
        if ("false".equalsIgnoreCase(logToStdoutEnv)) {
            logToStdout = false;
        }
        
        String logFormatEnv = System.getenv("IDEMPIERE_LOG_FORMAT");
        if (logFormatEnv != null) {
            logFormat = logFormatEnv.toLowerCase();
        }
    }
    
    /**
     * Get log file handler with stdout support
     */
    public static CLogFile get(boolean create, String fileName, boolean append) {
        CLogFile handler = new CLogFile();
        
        // Add file handler if enabled
        if (logToFile) {
            // ... existing file handler code ...
        }
        
        // Add stdout handler if enabled
        if (logToStdout) {
            ConsoleHandler consoleHandler = new ConsoleHandler();
            consoleHandler.setLevel(Level.ALL);
            
            if ("json".equals(logFormat)) {
                consoleHandler.setFormatter(new JsonFormatter());
            } else {
                consoleHandler.setFormatter(new SimpleFormatter());
            }
            
            handler.addHandler(consoleHandler);
        }
        
        return handler;
    }
    
    /**
     * JSON formatter for structured logging
     */
    private static class JsonFormatter extends Formatter {
        @Override
        public String format(LogRecord record) {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"timestamp\":\"").append(new java.util.Date(record.getMillis())).append("\",");
            json.append("\"level\":\"").append(record.getLevel()).append("\",");
            json.append("\"logger\":\"").append(record.getLoggerName()).append("\",");
            json.append("\"message\":\"").append(escapeJson(record.getMessage())).append("\"");
            
            if (record.getThrown() != null) {
                json.append(",\"exception\":\"").append(escapeJson(getStackTrace(record.getThrown()))).append("\"");
            }
            
            json.append("}\n");
            return json.toString();
        }
        
        private String escapeJson(String str) {
            if (str == null) return "";
            return str.replace("\\", "\\\\")
                     .replace("\"", "\\\"")
                     .replace("\n", "\\n")
                     .replace("\r", "\\r");
        }
        
        private String getStackTrace(Throwable t) {
            java.io.StringWriter sw = new java.io.StringWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(sw);
            t.printStackTrace(pw);
            return sw.toString();
        }
    }
}
```

---

## Session State Externalization

### Current Session Management

**File:** `org.adempiere.base/src/org/compiere/model/MSession.java`

**Key Methods:**
- `get(Properties ctx)` - Gets session from context
- `logout()` - Logs out session

### Target: Database-Backed Sessions

**Modify MSession to use database:**
```java
/**
 * Get session from database (already partially implemented)
 * Ensure all session data is in database, not memory
 */
public static MSession get(Properties ctx) {
    int AD_Session_ID = Env.getContextAsInt(ctx, Env.AD_SESSION_ID);
    if (AD_Session_ID == 0) {
        return null;
    }
    
    // Always load from database, not cache
    return new Query(ctx, Table_Name, "AD_Session_ID=?", null)
        .setParameters(AD_Session_ID)
        .first();
}

/**
 * Create new session in database
 */
public static MSession create(Properties ctx, String remoteAddr, String remoteHost) {
    MSession session = new MSession(ctx, 0, null);
    session.setRemote_Addr(remoteAddr);
    session.setRemote_Host(remoteHost);
    session.setProcessed(false);
    session.saveEx();
    
    // Set in context
    Env.setContext(ctx, Env.AD_SESSION_ID, session.getAD_Session_ID());
    
    return session;
}
```

### Redis Session Store (Optional, Phase 5)

**File to Create:** `org.adempiere.base/src/org/compiere/util/RedisSessionStore.java`

```java
package org.compiere.util;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

/**
 * Redis-based session store for stateless design
 */
public class RedisSessionStore {
    
    private static JedisPool jedisPool;
    
    static {
        String redisHost = System.getenv("IDEMPIERE_REDIS_HOST");
        String redisPort = System.getenv("IDEMPIERE_REDIS_PORT");
        
        if (redisHost != null && redisPort != null) {
            JedisPoolConfig config = new JedisPoolConfig();
            config.setMaxTotal(128);
            config.setMaxIdle(32);
            
            jedisPool = new JedisPool(
                config,
                redisHost,
                Integer.parseInt(redisPort),
                2000 // timeout
            );
        }
    }
    
    /**
     * Store session data in Redis
     */
    public static void storeSession(String sessionId, String sessionData, int ttlSeconds) {
        if (jedisPool == null) return;
        
        try (Jedis jedis = jedisPool.getResource()) {
            jedis.setex("session:" + sessionId, ttlSeconds, sessionData);
        }
    }
    
    /**
     * Retrieve session data from Redis
     */
    public static String getSession(String sessionId) {
        if (jedisPool == null) return null;
        
        try (Jedis jedis = jedisPool.getResource()) {
            return jedis.get("session:" + sessionId);
        }
    }
    
    /**
     * Delete session from Redis
     */
    public static void deleteSession(String sessionId) {
        if (jedisPool == null) return;
        
        try (Jedis jedis = jedisPool.getResource()) {
            jedis.del("session:" + sessionId);
        }
    }
}
```

---

## Dockerfile Examples

### Multi-Stage Dockerfile

**File to Create:** `Dockerfile`

```dockerfile
# Build stage
FROM maven:3.8-eclipse-temurin-17 AS build

WORKDIR /build

# Copy Maven configuration
COPY pom.xml .
COPY org.idempiere.parent/pom.xml org.idempiere.parent/

# Download dependencies (cached layer)
RUN mvn dependency:go-offline -f pom.xml || true

# Copy source code
COPY . .

# Build application
RUN mvn clean package -DskipTests -Dmaven.test.skip=true

# Release stage
FROM eclipse-temurin:17-jre

WORKDIR /opt/idempiere

# Copy OSGi bundles and runtime from build stage
COPY --from=build /build/org.adempiere.server-feature/target/products/org.adempiere.server.product/linux/gtk/x86_64/idempiereServer/plugins ./plugins/
COPY --from=build /build/org.adempiere.server-feature/jettyhome ./jettyhome/

# Create non-root user
RUN groupadd -r idempiere && useradd -r -g idempiere idempiere
RUN chown -R idempiere:idempiere /opt/idempiere

# Environment variables
ENV PORT=8080
ENV IDEMPIERE_DB_TYPE=postgresql
ENV IDEMPIERE_LOG_TO_FILE=false
ENV IDEMPIERE_LOG_TO_STDOUT=true

# Expose port
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# Switch to non-root user
USER idempiere

# Start application
CMD ["sh", "-c", "java -jar plugins/org.eclipse.equinox.launcher_*.jar -application org.adempiere.server.application"]
```

### .dockerignore

**File to Create:** `.dockerignore`

```
# Build artifacts
target/
*.jar
*.war
*.ear

# IDE files
.idea/
.vscode/
*.iml
*.ipr
*.iws

# OS files
.DS_Store
Thumbs.db

# Git
.git/
.gitignore

# Documentation
*.md
doc/

# Test files
**/test/
**/*Test.java
**/*Tests.java

# Migration files (large, not needed in image)
migration/
migration-historic/
```

---

## Kubernetes Manifests

### Deployment

**File to Create:** `k8s/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: idempiere
  labels:
    app: idempiere
spec:
  replicas: 1  # Start with 1, increase after stateless migration
  selector:
    matchLabels:
      app: idempiere
  template:
    metadata:
      labels:
        app: idempiere
    spec:
      containers:
      - name: idempiere
        image: idempiere:latest
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: PORT
          value: "8080"
        - name: IDEMPIERE_DB_HOST
          valueFrom:
            configMapKeyRef:
              name: idempiere-config
              key: db-host
        - name: IDEMPIERE_DB_NAME
          valueFrom:
            configMapKeyRef:
              name: idempiere-config
              key: db-name
        - name: IDEMPIERE_DB_USER
          valueFrom:
            secretKeyRef:
              name: idempiere-secrets
              key: db-user
        - name: IDEMPIERE_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: idempiere-secrets
              key: db-password
        - name: IDEMPIERE_LOG_TO_FILE
          value: "false"
        - name: IDEMPIERE_LOG_TO_STDOUT
          value: "true"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 3
        startupProbe:
          httpGet:
            path: /health/startup
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 30  # Allow up to 5 minutes for startup
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
```

### Service

**File to Create:** `k8s/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: idempiere
spec:
  type: ClusterIP
  selector:
    app: idempiere
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
```

### ConfigMap

**File to Create:** `k8s/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: idempiere-config
data:
  db-host: "postgres-service"
  db-port: "5432"
  db-name: "idempiere"
  db-type: "postgresql"
  cluster-enabled: "false"
  log-format: "json"
```

### Secrets

**File to Create:** `k8s/secrets.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: idempiere-secrets
type: Opaque
stringData:
  db-user: "adempiere"
  db-password: "changeme"  # Replace with actual password
```

**Note:** In production, use sealed secrets, external secrets operator, or cloud secrets manager.

---

## Testing Examples

### Test Configuration Loading

```java
@Test
public void testEnvironmentVariablePrecedence() {
    // Set environment variable
    System.setProperty("IDEMPIERE_DB_HOST", "test-host");
    
    // Should use environment variable
    String host = Ini.getProperty("DB_HOST");
    assertEquals("test-host", host);
    
    // Clear and should fallback to file
    System.clearProperty("IDEMPIERE_DB_HOST");
    // ... test file fallback
}
```

### Test Health Check

```bash
# Test liveness
curl http://localhost:8080/health

# Test readiness
curl http://localhost:8080/health/ready

# Test startup
curl http://localhost:8080/health/startup
```

### Test Docker Build

```bash
# Build image
docker build -t idempiere:test .

# Run container
docker run -d \
  --name idempiere-test \
  -p 8080:8080 \
  -e IDEMPIERE_DB_HOST=host.docker.internal \
  -e IDEMPIERE_DB_NAME=idempiere \
  -e IDEMPIERE_DB_USER=adempiere \
  -e IDEMPIERE_DB_PASSWORD=secret \
  idempiere:test

# Check logs
docker logs idempiere-test

# Test health
curl http://localhost:8080/health

# Cleanup
docker stop idempiere-test
docker rm idempiere-test
```

---

## Common Patterns

### Environment Variable Helper

```java
/**
 * Get value from environment variable or system property
 */
public static String getEnvOrProperty(String envVar, String sysProp, String defaultValue) {
    String value = System.getenv(envVar);
    if (value != null && !value.isEmpty()) {
        return value;
    }
    
    value = System.getProperty(sysProp);
    if (value != null && !value.isEmpty()) {
        return value;
    }
    
    return defaultValue;
}
```

### Configuration Validation Pattern

```java
public static void validateRequired(String key, String value) {
    if (value == null || value.isEmpty()) {
        throw new IllegalStateException(
            "Required configuration missing: " + key +
            ". Set environment variable " + key + " or configure in properties file."
        );
    }
}
```

---

**Document Version:** 1.0  
**Created:** 2025-01-27  
**Last Updated:** 2025-01-27

