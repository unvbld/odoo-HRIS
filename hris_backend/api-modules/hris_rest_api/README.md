# HRIS REST API Module

This module provides REST API endpoints for the HRIS Flutter application.

## Features

- **Authentication**: Login/logout with session management
- **Employee Management**: CRUD operations for employee data
- **Leave Management**: Create, approve, and track leave requests
- **Attendance Tracking**: Check-in/check-out functionality
- **CORS Support**: Full CORS support for Flutter apps
- **Error Handling**: Comprehensive error handling and logging

## API Endpoints

### Health Check
- `GET /api/health` - API health check
- `GET /api/version` - API version and endpoint information

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/profile` - Get current user profile
- `POST /api/auth/change-password` - Change user password

### Employees
- `GET /api/employees` - Get all employees (with pagination, search, filters)
- `GET /api/employees/<id>` - Get specific employee details
- `GET /api/departments` - Get all departments

### Leaves
- `GET /api/leaves` - Get leave requests (with filters)
- `POST /api/leaves` - Create new leave request
- `POST /api/leaves/<id>/approve` - Approve leave request
- `GET /api/leave-types` - Get available leave types
- `GET /api/leave-balance/<employee_id>` - Get employee leave balance

### Attendance
- `POST /api/attendance/checkin` - Employee check-in
- `POST /api/attendance/checkout` - Employee check-out
- `GET /api/attendance` - Get attendance records (with filters)
- `GET /api/attendance/status/<employee_id>` - Get current attendance status

## Installation

1. Place this module in your `api-modules` directory
2. Update `docker-compose.yml` to include the api-modules path
3. Update the addons list in Odoo
4. Install the module
5. The API endpoints will be available at your Odoo base URL

## API Response Format

All API endpoints return JSON responses in the following format:

```json
{
    "success": true/false,
    "message": "Response message",
    "data": { ... },
    "timestamp": "2025-06-24T10:30:00"
}
```

## Error Codes

- `200` - Success
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `500` - Internal Server Error

## Usage Examples

### Login
```bash
curl -X POST http://localhost:8069/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin"}'
```

### Get Employees
```bash
curl -X GET "http://localhost:8069/api/employees?limit=10&search=john" \
  -H "Cookie: session_id=your_session_id"
```

### Create Leave Request
```bash
curl -X POST http://localhost:8069/api/leaves \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=your_session_id" \
  -d '{
    "employee_id": 1,
    "holiday_status_id": 1,
    "request_date_from": "2025-07-01",
    "request_date_to": "2025-07-05",
    "name": "Summer Vacation"
  }'
```
