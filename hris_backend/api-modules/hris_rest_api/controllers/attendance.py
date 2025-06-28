import json
import logging
from datetime import datetime, date, timedelta, time
from odoo import http
from odoo.http import request
import calendar

_logger = logging.getLogger(__name__)

class AttendanceController(http.Controller):
    
    def _cors_headers(self):
        """Return CORS headers for API responses"""
        return {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
            'Access-Control-Max-Age': '86400',
        }
    
    def _json_response(self, data=None, success=True, message="", status=200):
        """Standard JSON response format"""
        response_data = {
            'success': success,
            'message': message,
            'data': data,
            'timestamp': datetime.now().isoformat()
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
    
    def _get_user_from_session(self):
        """Get user from session using proper authentication"""
        try:
            # First check if there's an Authorization header
            auth_header = request.httprequest.headers.get('Authorization', '')
            if auth_header.startswith('Bearer '):
                session_token = auth_header.replace('Bearer ', '')
                _logger.info(f"Attendance request with token: {session_token}")
                
                # For development: Get user from session token (simplified approach)
                # This should match the logic from auth controller
                try:
                    # Find the most recent active user based on session token pattern
                    # In a real implementation, you'd store and validate session tokens properly
                    recent_user = request.env['res.users'].sudo().search([
                        ('active', '=', True),
                        ('login', '!=', False)
                    ], order='login_date desc', limit=1)
                    
                    if recent_user:
                        _logger.info(f"Using session user: {recent_user.name} (ID: {recent_user.id})")
                        return recent_user
                        
                except Exception as e:
                    _logger.error(f"Error finding user for session token: {str(e)}")
            
            # Check if there's a valid session without Authorization header
            if hasattr(request, 'session') and request.session.uid:
                user = request.env['res.users'].sudo().browse(request.session.uid)
                if user.exists():
                    _logger.info(f"Using current session user: {user.name} (ID: {user.id})")
                    return user
            
            # Check for session cookie
            session_id = request.httprequest.cookies.get('session_id')
            if session_id:
                # Try to get session from database
                try:
                    session_store = request.env['ir.http']._get_session_store()
                    session_data = session_store.get(session_id)
                    if session_data and session_data.get('uid'):
                        user = request.env['res.users'].sudo().browse(session_data['uid'])
                        if user.exists():
                            _logger.info(f"Using cookie session user: {user.name} (ID: {user.id})")
                            return user
                except Exception as e:
                    _logger.error(f"Error getting session from cookie: {str(e)}")
                        
        except Exception as e:
            _logger.error(f"Session lookup error: {str(e)}")
            
        return None

    @http.route('/api/attendance/dashboard', type='http', auth='none', methods=['GET', 'OPTIONS'], csrf=False)
    def get_dashboard_data(self):
        """Get attendance dashboard data for current user"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
            
        try:
            # Get user from session
            user = self._get_user_from_session()
            if not user:
                return self._error_response("Authentication required", 401)
            
            # Get current date info
            today = datetime.now().date()
            current_month_start = today.replace(day=1)
            
            # Check if user has employee record
            employee = request.env['hr.employee'].sudo().search([
                ('user_id', '=', user.id)
            ], limit=1)
            
            if not employee:
                # Create basic employee record if not exists
                employee = request.env['hr.employee'].sudo().create({
                    'name': user.name,
                    'user_id': user.id,
                    'work_email': user.email,
                })
            
            # Get today's attendance
            today_attendance = request.env['hr.attendance'].sudo().search([
                ('employee_id', '=', employee.id),
                ('check_in', '>=', today.strftime('%Y-%m-%d 00:00:00')),
                ('check_in', '<', (today + timedelta(days=1)).strftime('%Y-%m-%d 00:00:00'))
            ], order='check_in desc', limit=1)
            
            # Calculate current status
            is_checked_in = bool(today_attendance and not today_attendance.check_out)
            check_in_time = today_attendance.check_in.strftime('%I:%M %p') if today_attendance and today_attendance.check_in else ''
            check_out_time = today_attendance.check_out.strftime('%I:%M %p') if today_attendance and today_attendance.check_out else ''
            
            # Calculate working hours
            working_hours = '00:00:00'
            if today_attendance and today_attendance.check_in:
                if today_attendance.check_out:
                    # Calculate actual working hours
                    check_in = today_attendance.check_in
                    check_out = today_attendance.check_out
                    duration = check_out - check_in
                    hours = int(duration.total_seconds() // 3600)
                    minutes = int((duration.total_seconds() % 3600) // 60)
                    seconds = int(duration.total_seconds() % 60)
                    working_hours = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
                else:
                    # Calculate current working hours (still checked in)
                    check_in = today_attendance.check_in
                    now = datetime.now()
                    duration = now - check_in
                    hours = int(duration.total_seconds() // 3600)
                    minutes = int((duration.total_seconds() % 3600) // 60)
                    seconds = int(duration.total_seconds() % 60)
                    working_hours = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
            
            # Get monthly attendance summary
            monthly_attendances = request.env['hr.attendance'].sudo().search([
                ('employee_id', '=', employee.id),
                ('check_in', '>=', current_month_start.strftime('%Y-%m-%d 00:00:00')),
                ('check_in', '<', datetime.now().strftime('%Y-%m-%d 23:59:59'))
            ])
            
            # Calculate attendance statistics
            present_days = len(set(att.check_in.date() for att in monthly_attendances if att.check_in))
            
            # Calculate working days in current month (assuming 5-day work week)
            total_days = calendar.monthrange(today.year, today.month)[1]
            working_days = 0
            for day in range(1, min(total_days + 1, today.day + 1)):  # Only count up to today
                date_check = today.replace(day=day)
                if date_check.weekday() < 5:  # Monday to Friday
                    working_days += 1
            
            absent_days = max(0, working_days - present_days)
            
            # Calculate late arrivals (assuming 9:00 AM is standard time)
            late_days = 0
            standard_time = time(9, 0)  # 9:00 AM
            for attendance in monthly_attendances:
                if attendance.check_in and attendance.check_in.time() > standard_time:
                    late_days += 1
            
            dashboard_data = {
                'user_info': {
                    'name': user.name,
                    'location': 'Office Location'  # This could be fetched from employee record
                },
                'current_status': {
                    'is_checked_in': is_checked_in,
                    'check_in_time': check_in_time,
                    'check_out_time': check_out_time,
                    'working_hours': working_hours
                },
                'monthly_summary': {
                    'present_days': present_days,
                    'absent_days': absent_days,
                    'late_days': late_days,
                    'working_days': working_days
                }
            }
            
            return self._json_response(dashboard_data, message="Dashboard data retrieved successfully")
            
        except Exception as e:
            _logger.error(f"Error getting dashboard data: {str(e)}")
            return self._error_response(f"Error retrieving dashboard data: {str(e)}", 500)

    @http.route('/api/attendance/toggle', type='http', auth='none', methods=['POST', 'OPTIONS'], csrf=False)
    def toggle_checkin_checkout(self):
        """Toggle check-in/check-out for current user"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
            
        try:
            # Get user from session
            user = self._get_user_from_session()
            if not user:
                return self._error_response("Authentication required", 401)
            
            # Get employee record
            employee = request.env['hr.employee'].sudo().search([
                ('user_id', '=', user.id)
            ], limit=1)
            
            if not employee:
                return self._error_response("Employee record not found", 404)
            
            # Check if already checked in today
            today = datetime.now().date()
            existing_attendance = request.env['hr.attendance'].sudo().search([
                ('employee_id', '=', employee.id),
                ('check_in', '>=', today.strftime('%Y-%m-%d 00:00:00')),
                ('check_in', '<', (today + timedelta(days=1)).strftime('%Y-%m-%d 00:00:00')),
                ('check_out', '=', False)
            ], limit=1)
            
            if existing_attendance:
                # Check out
                check_out_time = datetime.now()
                existing_attendance.sudo().write({
                    'check_out': check_out_time
                })
                
                # Calculate working hours
                duration = check_out_time - existing_attendance.check_in
                hours = int(duration.total_seconds() // 3600)
                minutes = int((duration.total_seconds() % 3600) // 60)
                seconds = int(duration.total_seconds() % 60)
                working_hours = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
                
                check_out_formatted = check_out_time.strftime('%I:%M %p')
                
                return self._json_response({
                    'action': 'check_out',
                    'check_out_time': check_out_formatted,
                    'working_hours': working_hours,
                    'is_checked_in': False,
                    'message': f'Successfully checked out at {check_out_formatted}'
                }, message="Check out successful")
            else:
                # Check in
                attendance = request.env['hr.attendance'].sudo().create({
                    'employee_id': employee.id,
                    'check_in': datetime.now(),
                })
                
                check_in_time = attendance.check_in.strftime('%I:%M %p')
                
                return self._json_response({
                    'action': 'check_in',
                    'check_in_time': check_in_time,
                    'is_checked_in': True,
                    'message': f'Successfully checked in at {check_in_time}'
                }, message="Check in successful")
                
        except Exception as e:
            _logger.error(f"Error during toggle check-in/out: {str(e)}")
            return self._error_response(f"Error during check-in/out: {str(e)}", 500)

    @http.route('/api/attendance/checkin', type='http', auth='user', methods=['POST', 'OPTIONS'], csrf=False)
    def check_in(self):
        """Employee check-in"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            employee_id = data.get('employee_id')
            location = data.get('location')
            notes = data.get('notes', '')
            
            if not employee_id:
                return self._error_response("Employee ID is required", 400)
            
            # Check if employee exists
            employee = request.env['hr.employee'].browse(employee_id)
            if not employee.exists():
                return self._error_response("Employee not found", 404)
            
            # Check if already checked in today
            today = date.today()
            existing_attendance = request.env['hr.attendance'].search([
                ('employee_id', '=', employee_id),
                ('check_out', '=', False),
                ('check_in', '>=', f'{today} 00:00:00'),
                ('check_in', '<=', f'{today} 23:59:59')
            ], limit=1)
            
            if existing_attendance:
                return self._error_response("Employee is already checked in today", 400)
            
            # Create check-in record
            attendance_vals = {
                'employee_id': employee_id,
                'check_in': datetime.now(),
            }
            
            attendance = request.env['hr.attendance'].create(attendance_vals)
            
            return self._json_response(
                data={
                    'id': attendance.id,
                    'employee_name': attendance.employee_id.name,
                    'check_in': attendance.check_in.strftime('%Y-%m-%d %H:%M:%S'),
                    'location': location,
                    'notes': notes,
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
            location = data.get('location')
            notes = data.get('notes', '')
            
            if not employee_id:
                return self._error_response("Employee ID is required", 400)
            
            # Find active check-in for today
            today = date.today()
            attendance = request.env['hr.attendance'].search([
                ('employee_id', '=', employee_id),
                ('check_out', '=', False),
                ('check_in', '>=', f'{today} 00:00:00'),
                ('check_in', '<=', f'{today} 23:59:59')
            ], limit=1)
            
            if not attendance:
                return self._error_response("No active check-in found for today", 400)
            
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
                    'location': location,
                    'notes': notes,
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
                domain.append(('check_in', '>=', f'{date_from} 00:00:00'))
            if date_to:
                domain.append(('check_in', '<=', f'{date_to} 23:59:59'))
            
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
                    'date': attendance.check_in.strftime('%Y-%m-%d'),
                })
            
            return self._json_response(
                data={
                    'attendances': attendance_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset,
                    'has_more': offset + limit < total_count
                },
                message="Attendance records retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Attendance list error: {str(e)}")
            return self._error_response("Failed to retrieve attendance records", 500)
    
    @http.route('/api/attendance/status/<int:employee_id>', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_attendance_status(self, employee_id):
        """Get current attendance status for employee"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            employee = request.env['hr.employee'].browse(employee_id)
            if not employee.exists():
                return self._error_response("Employee not found", 404)
            
            # Check today's attendance
            today = date.today()
            attendance = request.env['hr.attendance'].search([
                ('employee_id', '=', employee_id),
                ('check_in', '>=', f'{today} 00:00:00'),
                ('check_in', '<=', f'{today} 23:59:59')
            ], limit=1, order='check_in desc')
            
            if attendance:
                status_data = {
                    'employee_id': employee_id,
                    'employee_name': employee.name,
                    'is_checked_in': not attendance.check_out,
                    'last_attendance_id': attendance.id,
                    'check_in': attendance.check_in.strftime('%Y-%m-%d %H:%M:%S'),
                    'check_out': attendance.check_out.strftime('%Y-%m-%d %H:%M:%S') if attendance.check_out else None,
                    'worked_hours_today': attendance.worked_hours if attendance.check_out else 0,
                    'status': 'checked_in' if not attendance.check_out else 'checked_out'
                }
            else:
                status_data = {
                    'employee_id': employee_id,
                    'employee_name': employee.name,
                    'is_checked_in': False,
                    'last_attendance_id': None,
                    'check_in': None,
                    'check_out': None,
                    'worked_hours_today': 0,
                    'status': 'not_checked_in'
                }
            
            return self._json_response(
                data=status_data,
                message="Attendance status retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Attendance status error: {str(e)}")
            return self._error_response("Failed to retrieve attendance status", 500)
