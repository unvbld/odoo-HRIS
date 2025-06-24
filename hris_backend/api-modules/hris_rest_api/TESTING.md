# HRIS REST API Testing Guide

Panduan lengkap untuk testing HRIS REST API menggunakan berbagai tools dan methods.

## 🚀 Quick Start

### Prerequisites
1. **Docker Setup**: Docker containers running
2. **Odoo Server**: Running on http://localhost:8069
3. **REST API Module**: Installed and enabled  
4. **Test User**: Created with credentials
5. **Test Tools**: PowerShell, cURL, Postman, or HTTPie

### Environment Setup
```bash
# Navigate to project directory
cd f:\KULIAH\B\Magang\WIBICON\haris\hris_backend

# Start Docker containers
docker-compose up -d

# Wait for containers to be ready (about 30 seconds)
docker-compose ps
```

### Module Installation
1. Open browser: http://localhost:8069
2. Login to Odoo (admin credentials)
3. Go to Apps > Search "HRIS REST API" > Install
4. Wait for installation to complete

### Create Test User
```bash
# Access Odoo shell
docker exec -it hris_backend-web-1 /usr/bin/odoo shell -d odoo --no-http --config=/etc/odoo/odoo.conf

# Create test user (paste this in shell)
user_vals = {
    'name': 'API Test User',
    'login': 'apitest@test.com',
    'password': 'test123'
}
new_user = env['res.users'].sudo().create(user_vals)
env.cr.commit()
print('Created user:', new_user.login, 'ID:', new_user.id)
exit()
```

## 🧪 Testing Methods

### Method 1: PowerShell (Recommended for Windows)

#### 1. Health Check Test
```powershell
# Test if API is running
Invoke-RestMethod -Uri "http://localhost:8069/api/health" -Method GET

# Expected output:
# status  message
# ------  -------
# ok      HRIS REST API is running
```

#### 2. Authentication Flow
```powershell
# Login and get session token
$loginData = @{
    username = "apitest@test.com"
    password = "test123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8069/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData

# Extract session token
$sessionToken = $loginResponse.data.session_token
Write-Host "Session Token: $sessionToken"

# Test authenticated endpoint
$headers = @{"Cookie" = "session_id=$sessionToken"}
Invoke-RestMethod -Uri "http://localhost:8069/api/auth/profile" -Method GET -Headers $headers

# Logout
Invoke-RestMethod -Uri "http://localhost:8069/api/auth/logout" -Method POST -Headers $headers
```

#### 3. Complete PowerShell Test Script
Save this as `test-api.ps1`:
```powershell
param(
    [string]$BaseUrl = "http://localhost:8069",
    [string]$Username = "apitest@test.com",
    [string]$Password = "test123"
)

Write-Host "🧪 Testing HRIS REST API" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow

# Test 1: Health Check
Write-Host "`n1. Testing Health Check..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/api/health" -Method GET
    Write-Host "✅ Health Check: $($health.status) - $($health.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Login
Write-Host "`n2. Testing Login..." -ForegroundColor Cyan
try {
    $loginData = @{
        username = $Username
        password = $Password
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData
    $sessionToken = $loginResponse.data.session_token
    Write-Host "✅ Login Successful: User ID $($loginResponse.data.user_id)" -ForegroundColor Green
    Write-Host "   Session Token: $sessionToken" -ForegroundColor Gray
} catch {
    Write-Host "❌ Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Profile
Write-Host "`n3. Testing Profile..." -ForegroundColor Cyan
try {
    $headers = @{"Cookie" = "session_id=$sessionToken"}
    $profile = Invoke-RestMethod -Uri "$BaseUrl/api/auth/profile" -Method GET -Headers $headers
    Write-Host "✅ Profile Retrieved: $($profile.data.name)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Profile Test: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test 4: Employees
Write-Host "`n4. Testing Employees..." -ForegroundColor Cyan
try {
    $employees = Invoke-RestMethod -Uri "$BaseUrl/api/employees" -Method GET -Headers $headers
    Write-Host "✅ Employees Retrieved" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Employees Test: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test 5: Logout
Write-Host "`n5. Testing Logout..." -ForegroundColor Cyan
try {
    $logout = Invoke-RestMethod -Uri "$BaseUrl/api/auth/logout" -Method POST -Headers $headers
    Write-Host "✅ Logout Successful" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Logout Test: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n🎉 API Testing Complete!" -ForegroundColor Green
```

### Method 2: cURL (Cross-platform)

#### Basic Commands
```bash
# Health Check
curl -X GET http://localhost:8069/api/health

# Login
curl -X POST http://localhost:8069/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "apitest@test.com", "password": "test123"}'

# Profile (replace SESSION_TOKEN)
curl -X GET http://localhost:8069/api/auth/profile \
  -H "Cookie: session_id=SESSION_TOKEN"

# Logout
curl -X POST http://localhost:8069/api/auth/logout \
  -H "Cookie: session_id=SESSION_TOKEN"
```

### Method 3: VS Code REST Client

Create a file `test-api.http`:
```http
### Health Check
GET http://localhost:8069/api/health

### Login
POST http://localhost:8069/api/auth/login
Content-Type: application/json

{
  "username": "apitest@test.com",
  "password": "test123"
}

### Profile (replace with actual session token)
GET http://localhost:8069/api/auth/profile
Cookie: session_id=YOUR_SESSION_TOKEN_HERE

### Employees
GET http://localhost:8069/api/employees
Cookie: session_id=YOUR_SESSION_TOKEN_HERE

### Logout
POST http://localhost:8069/api/auth/logout
Cookie: session_id=YOUR_SESSION_TOKEN_HERE
```

## 📊 Expected Response Formats

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* actual data */ },
  "timestamp": "2025-06-24T06:31:13.520045"
}
```

### Login Success Response
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user_id": 8,
    "username": "apitest@test.com",
    "session_token": "5a32652eafab0f5cdf22b070687eb813f68a44d6",
    "login_time": "2025-06-24T06:31:13.520036",
    "message": "Authentication successful"
  },
  "timestamp": "2025-06-24T06:31:13.520045"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "data": null,
  "timestamp": "2025-06-24T06:31:13.520045"
}
```

## 🔧 Troubleshooting

### Common Issues & Solutions

#### 1. "Connection refused" or "404 Not Found"
```bash
# Check container status
docker-compose ps

# Check if containers are running
docker-compose up -d

# Check Odoo logs
docker logs hris_backend-web-1 --tail 20
```

#### 2. "401 Unauthorized" on login
```bash
# Check if user exists
docker exec -it hris_backend-db-1 psql -U odoo -d odoo -c "SELECT id, login, active FROM res_users WHERE active = true;"

# Create test user if missing (see setup section above)
```

#### 3. "Module not found" errors
```bash
# Check if module is installed
# Go to http://localhost:8069 > Apps > Search "HRIS REST API"

# Restart containers if needed
docker-compose restart
```

### Debug Commands
```bash
# View all logs
docker-compose logs

# View specific service logs
docker logs hris_backend-web-1 --tail 50
docker logs hris_backend-db-1 --tail 20

# Check database connection
docker exec -it hris_backend-db-1 psql -U odoo -d odoo -c "\dt"

# Restart everything
docker-compose down && docker-compose up -d
```

## 🎯 Test Checklist

- [ ] Health check endpoint responds with `ok` status
- [ ] Login with valid credentials returns session token
- [ ] Login with invalid credentials returns 401 error
- [ ] Session token is valid format (long string)
- [ ] Authenticated endpoints accept session token
- [ ] Logout endpoint clears session
- [ ] CORS headers are present in responses
- [ ] Error responses have consistent JSON format
- [ ] All endpoints return proper HTTP status codes
- [ ] Response times are reasonable (< 2 seconds)

---

### Using curl:
```bash
curl -X GET http://localhost:8069/api/health
```

### Using VS Code REST Client:
```http
GET http://localhost:8069/api/health
```

Expected Response:
```json
{
    "success": true,
    "message": "API is running successfully",
    "data": {
        "status": "healthy",
        "service": "HRIS REST API",
        "version": "1.0.0"
    },
    "timestamp": "2025-06-24T11:50:00"
}
```

## 2. Authentication Tests

### Login Test
```bash
curl -X POST http://localhost:8069/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin"
  }'
```

### VS Code REST Client:
```http
POST http://localhost:8069/api/auth/login
Content-Type: application/json

{
    "username": "admin",
    "password": "admin"
}
```

Expected Response:
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user_id": 2,
        "username": "admin",
        "name": "Administrator",
        "email": "admin@example.com",
        "session_token": "session_id_here",
        "employee_id": 1,
        "employee_name": "Administrator",
        "department": "Management",
        "job_title": "Administrator",
        "login_time": "2025-06-24T11:50:00"
    }
}
```

### Get Profile (requires login)
```bash
curl -X GET http://localhost:8069/api/auth/profile \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

## 3. Employee Tests

### Get All Employees
```bash
curl -X GET "http://localhost:8069/api/employees?limit=10" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

### VS Code REST Client:
```http
GET http://localhost:8069/api/employees?limit=10&search=admin
Cookie: session_id=YOUR_SESSION_ID
```

### Get Specific Employee
```http
GET http://localhost:8069/api/employees/1
Cookie: session_id=YOUR_SESSION_ID
```

### Get Departments
```http
GET http://localhost:8069/api/departments
Cookie: session_id=YOUR_SESSION_ID
```

## 4. Leave Management Tests

### Get Leave Types
```http
GET http://localhost:8069/api/leave-types
Cookie: session_id=YOUR_SESSION_ID
```

### Create Leave Request
```http
POST http://localhost:8069/api/leaves
Content-Type: application/json
Cookie: session_id=YOUR_SESSION_ID

{
    "employee_id": 1,
    "holiday_status_id": 1,
    "request_date_from": "2025-07-01",
    "request_date_to": "2025-07-05",
    "name": "Summer Vacation",
    "notes": "Family vacation",
    "auto_submit": true
}
```

### Get Leave Requests
```http
GET http://localhost:8069/api/leaves?employee_id=1&limit=10
Cookie: session_id=YOUR_SESSION_ID
```

### Get Leave Balance
```http
GET http://localhost:8069/api/leave-balance/1
Cookie: session_id=YOUR_SESSION_ID
```

## 5. Attendance Tests

### Check-in
```http
POST http://localhost:8069/api/attendance/checkin
Content-Type: application/json
Cookie: session_id=YOUR_SESSION_ID

{
    "employee_id": 1,
    "location": "Office",
    "notes": "On time"
}
```

### Check Attendance Status
```http
GET http://localhost:8069/api/attendance/status/1
Cookie: session_id=YOUR_SESSION_ID
```

### Check-out
```http
POST http://localhost:8069/api/attendance/checkout
Content-Type: application/json
Cookie: session_id=YOUR_SESSION_ID

{
    "employee_id": 1,
    "location": "Office",
    "notes": "End of day"
}
```

### Get Attendance Records
```http
GET http://localhost:8069/api/attendance?employee_id=1&date_from=2025-06-01&date_to=2025-06-30
Cookie: session_id=YOUR_SESSION_ID
```

## Testing Steps:

1. **Start Odoo**: Make sure Docker containers are running
2. **Health Check**: Test `/api/health` to ensure API is accessible
3. **Install Module**: Go to Odoo Apps and install "HRIS REST API" module
4. **Login**: Test authentication endpoint
5. **Test Other Endpoints**: Use the session_id from login response

## Common Issues:

1. **404 Errors**: Module not installed or wrong URL
2. **401 Unauthorized**: Session expired or invalid credentials
3. **500 Internal Server Error**: Check Odoo logs for detailed error

## VS Code REST Client Extension
Install the "REST Client" extension for VS Code to easily test APIs using the `.http` files.
