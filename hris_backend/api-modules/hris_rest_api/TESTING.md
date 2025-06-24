# HRIS API Testing Guide

## Prerequisites
1. Odoo server running on http://localhost:8069
2. REST API module installed and enabled
3. Test tools: curl, Postman, or VS Code REST Client

## 1. Health Check Test

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
