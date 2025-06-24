import json
import logging
from datetime import datetime, timedelta
from odoo import http
from odoo.http import request
import werkzeug.wrappers

_logger = logging.getLogger(__name__)

class AuthController(http.Controller):
    
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
    
    @http.route('/api/auth/login', type='http', auth='none', methods=['POST', 'OPTIONS'], csrf=False)
    def login(self):
        """Login endpoint"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            username = data.get('username')
            password = data.get('password')
            
            if not username or not password:
                return self._error_response("Username and password are required", 400)
            
            # Authenticate user
            try:
                uid = request.session.authenticate(request.session.db, username, password)
                if uid:
                    user = request.env['res.users'].browse(uid)
                    employee = request.env['hr.employee'].search([('user_id', '=', uid)], limit=1)
                    
                    # Create session token (simplified - in production use proper JWT)
                    session_token = request.session.sid
                    
                    user_data = {
                        'user_id': user.id,
                        'username': user.login,
                        'name': user.name,
                        'email': user.email,
                        'session_token': session_token,
                        'employee_id': employee.id if employee else None,
                        'employee_name': employee.name if employee else None,
                        'department': employee.department_id.name if employee and employee.department_id else None,
                        'job_title': employee.job_id.name if employee and employee.job_id else None,
                        'login_time': datetime.now().isoformat(),
                    }
                    
                    return self._json_response(
                        data=user_data,
                        message="Login successful"
                    )
                else:
                    return self._error_response("Invalid credentials", 401)
                    
            except Exception as e:
                _logger.error(f"Authentication error: {str(e)}")
                return self._error_response("Authentication failed", 401)
                
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Login error: {str(e)}")
            return self._error_response("Internal server error", 500)
    
    @http.route('/api/auth/logout', type='http', auth='user', methods=['POST', 'OPTIONS'], csrf=False)
    def logout(self):
        """Logout endpoint"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            request.session.logout()
            return self._json_response(message="Logout successful")
        except Exception as e:
            _logger.error(f"Logout error: {str(e)}")
            return self._error_response("Logout failed", 500)
    
    @http.route('/api/auth/profile', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_profile(self):
        """Get current user profile"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            user = request.env.user
            employee = request.env['hr.employee'].search([('user_id', '=', user.id)], limit=1)
            
            profile_data = {
                'user_id': user.id,
                'username': user.login,
                'name': user.name,
                'email': user.email,
                'employee_id': employee.id if employee else None,
                'employee_name': employee.name if employee else None,
                'department': employee.department_id.name if employee and employee.department_id else None,
                'job_title': employee.job_id.name if employee and employee.job_id else None,
                'work_phone': employee.work_phone if employee else None,
                'mobile_phone': employee.mobile_phone if employee else None,
                'work_email': employee.work_email if employee else None,
                'manager': employee.parent_id.name if employee and employee.parent_id else None,
                'last_login': user.login_date.isoformat() if user.login_date else None,
            }
            
            return self._json_response(
                data=profile_data,
                message="Profile retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Profile error: {str(e)}")
            return self._error_response("Failed to retrieve profile", 500)
    
    @http.route('/api/auth/change-password', type='http', auth='user', methods=['POST', 'OPTIONS'], csrf=False)
    def change_password(self):
        """Change user password"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            old_password = data.get('old_password')
            new_password = data.get('new_password')
            
            if not old_password or not new_password:
                return self._error_response("Old password and new password are required", 400)
            
            # Verify old password
            user = request.env.user
            try:
                request.env['res.users'].check_credentials(user.id, old_password)
            except:
                return self._error_response("Invalid old password", 401)
            
            # Update password
            user.write({'password': new_password})
            
            return self._json_response(message="Password changed successfully")
            
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Change password error: {str(e)}")
            return self._error_response("Failed to change password", 500)
