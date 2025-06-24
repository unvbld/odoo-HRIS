import json
import logging
from datetime import datetime
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class AttendanceController(http.Controller):
    
    def _cors_headers(self):
        """Return CORS headers for API responses"""
        return {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '86400',
        }
    
    def _json_response(self, data=None, success=True, message="", status=200):
        """Standard JSON response format"""
        response_data = {
            'success': success,
            'message': message,
            'data': data
        }
        
        response = request.make_response(
            json.dumps(response_data, default=str),
            headers={
                'Content-Type': 'application/json',
                **self._cors_headers()
            }
        )
        response.status_code = status
        return response
    
    def _error_response(self, message, status=400):
        """Standard error response"""
        return self._json_response(
            data=None,
            success=False,
            message=message,
            status=status
        )
    
    @http.route('/api/attendance/checkin', type='http', auth='user', methods=['POST', 'OPTIONS'], csrf=False)
    def check_in(self):
        """Employee check-in"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            employee_id = data.get('employee_id')
            
            if not employee_id:
                return self._error_response("Employee ID is required", 400)
            
            # Check if employee exists
            employee = request.env['hr.employee'].browse(employee_id)
            if not employee.exists():
                return self._error_response("Employee not found", 404)
            
            # Check if already checked in
            existing_attendance = request.env['hr.attendance'].search([
                ('employee_id', '=', employee_id),
                ('check_out', '=', False)
            ], limit=1)
            
            if existing_attendance:
                return self._error_response("Employee is already checked in", 400)
            
            # Create check-in record
            attendance = request.env['hr.attendance'].create({
                'employee_id': employee_id,
                'check_in': datetime.now(),
            })
            
            return self._json_response(
                data={
                    'id': attendance.id,
                    'employee_name': attendance.employee_id.name,
                    'check_in': attendance.check_in.strftime('%Y-%m-%d %H:%M:%S'),
                },
                message="Check-in successful"
            )
            
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Check-in error: {str(e)}")
            return self._error_response("Check-in failed", 500)
    
    @http.route('/api/attendance/checkout', type='http', auth='user', methods=['POST', 'OPTIONS'], csrf=False)
    def check_out(self):
        """Employee check-out"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            employee_id = data.get('employee_id')
            
            if not employee_id:
                return self._error_response("Employee ID is required", 400)
            
            # Find active check-in
            attendance = request.env['hr.attendance'].search([
                ('employee_id', '=', employee_id),
                ('check_out', '=', False)
            ], limit=1)
            
            if not attendance:
                return self._error_response("No active check-in found", 400)
            
            # Update with check-out time
            attendance.write({
                'check_out': datetime.now()
            })
            
            return self._json_response(
                data={
                    'id': attendance.id,
                    'employee_name': attendance.employee_id.name,
                    'check_in': attendance.check_in.strftime('%Y-%m-%d %H:%M:%S'),
                    'check_out': attendance.check_out.strftime('%Y-%m-%d %H:%M:%S'),
                    'worked_hours': attendance.worked_hours,
                },
                message="Check-out successful"
            )
            
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Check-out error: {str(e)}")
            return self._error_response("Check-out failed", 500)
    
    @http.route('/api/attendance', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_attendance(self):
        """Get attendance records"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get query parameters
            limit = int(request.httprequest.args.get('limit', 20))
            offset = int(request.httprequest.args.get('offset', 0))
            employee_id = request.httprequest.args.get('employee_id')
            date_from = request.httprequest.args.get('date_from')
            date_to = request.httprequest.args.get('date_to')
            
            # Build domain
            domain = []
            if employee_id:
                domain.append(('employee_id', '=', int(employee_id)))
            if date_from:
                domain.append(('check_in', '>=', date_from))
            if date_to:
                domain.append(('check_in', '<=', date_to))
            
            # Get attendance records
            attendances = request.env['hr.attendance'].search(domain, limit=limit, offset=offset, order='check_in desc')
            total_count = request.env['hr.attendance'].search_count(domain)
            
            attendance_data = []
            for attendance in attendances:
                attendance_data.append({
                    'id': attendance.id,
                    'employee_name': attendance.employee_id.name,
                    'employee_id': attendance.employee_id.id,
                    'check_in': attendance.check_in.strftime('%Y-%m-%d %H:%M:%S'),
                    'check_out': attendance.check_out.strftime('%Y-%m-%d %H:%M:%S') if attendance.check_out else None,
                    'worked_hours': attendance.worked_hours,
                })
            
            return self._json_response(
                data={
                    'attendances': attendance_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset
                },
                message="Attendance records retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Attendance list error: {str(e)}")
            return self._error_response("Failed to retrieve attendance records", 500)
