# HRIS REST API Module

This module provides REST API endpoints for the HRIS Flutter application.

## Features

- Authentication (login/logout)
- Employee management
- Leave management
- Attendance tracking
- CORS support for Flutter apps

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/profile` - Get user profile

### Employees
- `GET /api/employees` - Get all employees
- `GET /api/employees/<id>` - Get specific employee

### Leaves
- `GET /api/leaves` - Get leave requests
- `POST /api/leaves` - Create leave request
- `GET /api/leave-types` - Get leave types

### Attendance
- `POST /api/attendance/checkin` - Employee check-in
- `POST /api/attendance/checkout` - Employee check-out
- `GET /api/attendance` - Get attendance records

### Health Check
- `GET /api/health` - API health check
- `GET /api/version` - API version info

## Installation

1. Place this module in your Odoo addons directory
2. Update the addons list
3. Install the module
4. The API endpoints will be available at your Odoo base URL

## Usage

All API endpoints return JSON responses in the following format:

```json
{
    "success": true/false,
    "message": "Response message",
    "data": { ... }
}
```
