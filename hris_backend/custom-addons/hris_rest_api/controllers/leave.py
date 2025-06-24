import json
import logging
from datetime import datetime
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class LeaveController(http.Controller):
    
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
    
    @http.route('/api/leaves', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_leaves(self):
        """Get leave requests"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            # Get query parameters
            limit = int(request.httprequest.args.get('limit', 20))
            offset = int(request.httprequest.args.get('offset', 0))
            employee_id = request.httprequest.args.get('employee_id')
            status = request.httprequest.args.get('status')
            
            # Build domain
            domain = []
            if employee_id:
                domain.append(('employee_id', '=', int(employee_id)))
            if status:
                domain.append(('state', '=', status))
            
            # Get leave requests
            leaves = request.env['hr.leave'].search(domain, limit=limit, offset=offset, order='create_date desc')
            total_count = request.env['hr.leave'].search_count(domain)
            
            leave_data = []
            for leave in leaves:
                leave_data.append({
                    'id': leave.id,
                    'employee_name': leave.employee_id.name,
                    'employee_id': leave.employee_id.id,
                    'leave_type': leave.holiday_status_id.name,
                    'leave_type_id': leave.holiday_status_id.id,
                    'request_date_from': leave.request_date_from.strftime('%Y-%m-%d') if leave.request_date_from else None,
                    'request_date_to': leave.request_date_to.strftime('%Y-%m-%d') if leave.request_date_to else None,
                    'number_of_days': leave.number_of_days,
                    'state': leave.state,
                    'name': leave.name,
                    'notes': leave.notes,
                    'create_date': leave.create_date.strftime('%Y-%m-%d %H:%M:%S') if leave.create_date else None,
                })
            
            return self._json_response(
                data={
                    'leaves': leave_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset
                },
                message="Leave requests retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Leave list error: {str(e)}")
            return self._error_response("Failed to retrieve leave requests", 500)
    
    @http.route('/api/leaves', type='http', auth='user', methods=['POST'], csrf=False)
    def create_leave(self):
        """Create new leave request"""
        try:
            # Get request data
            data = json.loads(request.httprequest.data.decode('utf-8'))
            
            required_fields = ['employee_id', 'holiday_status_id', 'request_date_from', 'request_date_to']
            for field in required_fields:
                if field not in data:
                    return self._error_response(f"Field '{field}' is required", 400)
            
            # Create leave request
            leave_vals = {
                'employee_id': data['employee_id'],
                'holiday_status_id': data['holiday_status_id'],
                'request_date_from': datetime.strptime(data['request_date_from'], '%Y-%m-%d').date(),
                'request_date_to': datetime.strptime(data['request_date_to'], '%Y-%m-%d').date(),
                'name': data.get('name', ''),
                'notes': data.get('notes', ''),
            }
            
            leave = request.env['hr.leave'].create(leave_vals)
            
            return self._json_response(
                data={
                    'id': leave.id,
                    'employee_name': leave.employee_id.name,
                    'leave_type': leave.holiday_status_id.name,
                    'request_date_from': leave.request_date_from.strftime('%Y-%m-%d'),
                    'request_date_to': leave.request_date_to.strftime('%Y-%m-%d'),
                    'state': leave.state,
                },
                message="Leave request created successfully"
            )
            
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Create leave error: {str(e)}")
            return self._error_response("Failed to create leave request", 500)
    
    @http.route('/api/leave-types', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_leave_types(self):
        """Get available leave types"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            leave_types = request.env['hr.leave.type'].search([])
            
            leave_type_data = []
            for leave_type in leave_types:
                leave_type_data.append({
                    'id': leave_type.id,
                    'name': leave_type.name,
                    'color': leave_type.color_name,
                    'allocation_type': leave_type.allocation_type,
                    'validity_start': leave_type.validity_start.strftime('%Y-%m-%d') if leave_type.validity_start else None,
                    'validity_stop': leave_type.validity_stop.strftime('%Y-%m-%d') if leave_type.validity_stop else None,
                })
            
            return self._json_response(
                data=leave_type_data,
                message="Leave types retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Leave types error: {str(e)}")
            return self._error_response("Failed to retrieve leave types", 500)
