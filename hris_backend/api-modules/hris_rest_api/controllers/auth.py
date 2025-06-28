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
        """Login endpoint with proper session management"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            username = data.get('username') or data.get('email')
            password = data.get('password')
            
            if not username or not password:
                return self._error_response("Username and password are required", 400)
            
            # Authenticate using Odoo's standard method
            try:
                uid = request.session.authenticate(request.session.db, username, password)
                
                if uid:
                    # Get user info
                    user = request.env['res.users'].sudo().browse(uid)
                    
                    # Update user's last login
                    user.sudo().write({'login_date': datetime.now()})
                    
                    # Get employee info if exists
                    employee = request.env['hr.employee'].sudo().search([
                        ('user_id', '=', uid)
                    ], limit=1)
                    
                    # Create comprehensive user data
                    user_data = {
                        'user_id': uid,
                        'username': user.login,
                        'name': user.name,
                        'email': user.email,
                        'session_token': request.session.sid,
                        'login_time': datetime.now().isoformat(),
                        'employee_id': employee.id if employee else None,
                        'employee_name': employee.name if employee else user.name,
                        'department': employee.department_id.name if employee and employee.department_id else None,
                        'job_title': employee.job_id.name if employee and employee.job_id else None,
                    }
                    
                    _logger.info(f"Login successful for user {user.login} with session {request.session.sid}")
                    
                    return self._json_response(
                        data=user_data,
                        message="Login successful"
                    )
                else:
                    return self._error_response("Invalid username or password", 401)
                    
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
    
    @http.route('/api/auth/profile', type='http', auth='none', methods=['GET', 'OPTIONS'], csrf=False)
    def get_profile(self):
        """Get current user profile"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get session token from cookie or Authorization header
            session_token = None
            
            # Check Cookie header
            if request.httprequest.cookies.get('session_id'):
                session_token = request.httprequest.cookies.get('session_id')
                _logger.info(f"Found session_id in cookie: {session_token}")
            
            # Check Authorization header
            auth_header = request.httprequest.headers.get('Authorization', '')
            _logger.info(f"Authorization header: {auth_header}")
            if auth_header.startswith('Bearer '):
                session_token = auth_header.replace('Bearer ', '')
                _logger.info(f"Found session_id in Bearer token: {session_token}")
            
            if not session_token:
                _logger.error("No session token found in request")
                return self._error_response("Session token required", 401)
            
            # Simple approach: use the session token to set session and get user
            # Set the session ID to the token we received
            original_sid = request.session.sid
            request.session.sid = session_token
            
            # Try to get user from session
            try:
                # Force session to load data from the new session ID
                request.session._get_session_data()
                
                if request.session.uid:
                    uid = request.session.uid
                    _logger.info(f"Successfully found user ID: {uid}")
                else:
                    _logger.error("No user ID found in session")
                    return self._error_response("Invalid or expired session", 401)
            except Exception as session_error:
                _logger.error(f"Session loading error: {str(session_error)}")
                # Restore original session ID
                request.session.sid = original_sid
                return self._error_response("Invalid or expired session", 401)
            user = request.env['res.users'].sudo().browse(uid)
            
            if not user.exists():
                return self._error_response("User not found", 404)
            
            employee = request.env['hr.employee'].sudo().search([('user_id', '=', user.id)], limit=1)
            
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
    
    @http.route('/api/auth/register', type='http', auth='none', methods=['POST', 'OPTIONS'], csrf=False)
    def register(self):
        """Register new user endpoint"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            username = data.get('username')
            email = data.get('email')
            password = data.get('password')
            name = data.get('name')
            confirm_password = data.get('confirm_password')
            
            # Validate required fields
            if not all([username, email, password, name]):
                return self._error_response("Username, email, password, and name are required", 400)
            
            # Validate password confirmation
            if confirm_password and password != confirm_password:
                return self._error_response("Password and confirm password do not match", 400)
            
            # Validate email format
            import re
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, email):
                return self._error_response("Invalid email format", 400)
            
            # Check if user already exists
            existing_user_by_login = request.env['res.users'].sudo().search([('login', '=', username)], limit=1)
            existing_user_by_email = request.env['res.users'].sudo().search([('email', '=', email)], limit=1)
            
            if existing_user_by_login:
                return self._error_response("Username already exists", 409)
            if existing_user_by_email:
                return self._error_response("Email already exists", 409)
            
            # Create new user
            try:
                # First, let's check if there are any triggers creating employees automatically
                # We'll try a different approach - disable hooks temporarily
                
                # Get basic user group and company first
                user_group = request.env.ref('base.group_user')
                main_company = request.env['res.company'].sudo().search([], limit=1)
                
                # Create partner first
                partner_vals = {
                    'name': name,
                    'email': email,
                    'is_company': False,
                    'supplier_rank': 0,
                    'customer_rank': 0,
                }
                partner = request.env['res.partner'].sudo().create(partner_vals)
                
                # Create user
                user_vals = {
                    'login': username,
                    'password': password,
                    'partner_id': partner.id,
                    'company_id': main_company.id,
                    'company_ids': [(6, 0, [main_company.id])],
                    'active': True,
                    'groups_id': [(6, 0, [user_group.id])],
                }
                
                # Try to override the create method to prevent employee creation during user creation
                old_employee_create = request.env['hr.employee'].__class__.create
                
                def no_auto_employee_create(self, vals_list):
                    # Skip automatic employee creation during user registration
                    if self.env.context.get('registering_user'):
                        return self.browse()
                    return old_employee_create(self, vals_list)
                
                # Monkey patch temporarily
                request.env['hr.employee'].__class__.create = no_auto_employee_create
                
                try:
                    # Create user with special context
                    new_user = request.env['res.users'].sudo().with_context(
                        registering_user=True,
                        no_reset_password=True,
                        mail_create_nosubscribe=True,
                        mail_notrack=True,
                        tracking_disable=True
                    ).create(user_vals)
                finally:
                    # Restore original method
                    request.env['hr.employee'].__class__.create = old_employee_create
                
                # Return success response  
                user_data = {
                    'user_id': new_user.id,
                    'username': username,
                    'name': name,
                    'email': email,
                    'created_at': datetime.now().isoformat(),
                }
                
                return self._json_response(
                    data=user_data,
                    message="User registered successfully"
                )
                
            except Exception as e:
                _logger.error(f"User creation error: {str(e)}")
                return self._error_response(f"Failed to create user: {str(e)}", 500)
                
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Registration error: {str(e)}")
            return self._error_response("Internal server error", 500)
