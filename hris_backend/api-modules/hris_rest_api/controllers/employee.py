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
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
            'Access-Control-Max-Age': '86400',
        }
    
    def _json_response(self, data=None, success=True, message="", status=200):
        """Standard JSON response format"""
        from datetime import datetime
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
    
    @http.route('/api/employees', type='http', auth='public', methods=['GET', 'OPTIONS'], csrf=False)
    def get_employees(self):
        """Get all employees"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get query parameters
            limit = int(request.httprequest.args.get('limit', 20))
            offset = int(request.httprequest.args.get('offset', 0))
            search = request.httprequest.args.get('search', '')
            department_id = request.httprequest.args.get('department_id')
            
            # Build domain for search
            domain = []
            if search:
                domain = [
                    '|', '|', 
                    ('name', 'ilike', search),
                    ('work_email', 'ilike', search),
                    ('department_id.name', 'ilike', search)
                ]
            if department_id:
                domain.append(('department_id', '=', int(department_id)))
            
            # Get employees
            employees = request.env['hr.employee'].search(domain, limit=limit, offset=offset, order='name asc')
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
                    'department_id': emp.department_id.id if emp.department_id else None,
                    'job_title': emp.job_id.name if emp.job_id else None,
                    'job_id': emp.job_id.id if emp.job_id else None,
                    'manager': emp.parent_id.name if emp.parent_id else None,
                    'manager_id': emp.parent_id.id if emp.parent_id else None,
                    'work_location': emp.address_id.name if emp.address_id else None,
                    'employee_type': emp.employee_type,
                    'active': emp.active,
                    'image_url': f'/web/image/hr.employee/{emp.id}/image_1920' if emp.image_1920 else None,
                })
            
            return self._json_response(
                data={
                    'employees': employee_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset,
                    'has_more': offset + limit < total_count
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
                'image_url': f'/web/image/hr.employee/{employee.id}/image_1920' if employee.image_1920 else None,
                'private_email': employee.private_email,
                'emergency_contact': employee.emergency_contact,
                'emergency_phone': employee.emergency_phone,
            }
            
            return self._json_response(
                data=employee_data,
                message="Employee details retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Employee detail error: {str(e)}")
            return self._error_response("Failed to retrieve employee details", 500)
    
    @http.route('/api/departments', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_departments(self):
        """Get all departments"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            departments = request.env['hr.department'].search([])
            
            department_data = []
            for dept in departments:
                department_data.append({
                    'id': dept.id,
                    'name': dept.name,
                    'manager': dept.manager_id.name if dept.manager_id else None,
                    'manager_id': dept.manager_id.id if dept.manager_id else None,
                    'parent_department': dept.parent_id.name if dept.parent_id else None,
                    'employee_count': len(dept.member_ids),
                })
            
            return self._json_response(
                data=department_data,
                message="Departments retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Departments error: {str(e)}")
            return self._error_response("Failed to retrieve departments", 500)
