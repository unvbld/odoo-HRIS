import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class EmployeeController(http.Controller):
    
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
    
    @http.route('/api/employees', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_employees(self):
        """Get all employees"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get query parameters
            limit = int(request.httprequest.args.get('limit', 20))
            offset = int(request.httprequest.args.get('offset', 0))
            search = request.httprequest.args.get('search', '')
            
            # Build domain for search
            domain = []
            if search:
                domain = [
                    '|', '|', 
                    ('name', 'ilike', search),
                    ('work_email', 'ilike', search),
                    ('department_id.name', 'ilike', search)
                ]
            
            # Get employees
            employees = request.env['hr.employee'].search(domain, limit=limit, offset=offset)
            total_count = request.env['hr.employee'].search_count(domain)
            
            employee_data = []
            for emp in employees:
                employee_data.append({
                    'id': emp.id,
                    'name': emp.name,
                    'work_email': emp.work_email,
                    'work_phone': emp.work_phone,
                    'mobile_phone': emp.mobile_phone,
                    'department': emp.department_id.name if emp.department_id else None,
                    'job_title': emp.job_id.name if emp.job_id else None,
                    'manager': emp.parent_id.name if emp.parent_id else None,
                    'work_location': emp.address_id.name if emp.address_id else None,
                    'employee_type': emp.employee_type,
                    'active': emp.active,
                })
            
            return self._json_response(
                data={
                    'employees': employee_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset
                },
                message="Employees retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Employee list error: {str(e)}")
            return self._error_response("Failed to retrieve employees", 500)
    
    @http.route('/api/employees/<int:employee_id>', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_employee(self, employee_id):
        """Get specific employee details"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            employee = request.env['hr.employee'].browse(employee_id)
            
            if not employee.exists():
                return self._error_response("Employee not found", 404)
            
            employee_data = {
                'id': employee.id,
                'name': employee.name,
                'work_email': employee.work_email,
                'work_phone': employee.work_phone,
                'mobile_phone': employee.mobile_phone,
                'department': employee.department_id.name if employee.department_id else None,
                'department_id': employee.department_id.id if employee.department_id else None,
                'job_title': employee.job_id.name if employee.job_id else None,
                'job_id': employee.job_id.id if employee.job_id else None,
                'manager': employee.parent_id.name if employee.parent_id else None,
                'manager_id': employee.parent_id.id if employee.parent_id else None,
                'work_location': employee.address_id.name if employee.address_id else None,
                'employee_type': employee.employee_type,
                'active': employee.active,
                'birthday': employee.birthday.strftime('%Y-%m-%d') if employee.birthday else None,
                'gender': employee.gender,
                'marital': employee.marital,
                'country': employee.country_id.name if employee.country_id else None,
                'identification_id': employee.identification_id,
                'passport_id': employee.passport_id,
            }
            
            return self._json_response(
                data=employee_data,
                message="Employee details retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Employee detail error: {str(e)}")
            return self._error_response("Failed to retrieve employee details", 500)
