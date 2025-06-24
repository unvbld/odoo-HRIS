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
            date_from = request.httprequest.args.get('date_from')
            date_to = request.httprequest.args.get('date_to')
            
            # Build domain
            domain = []
            if employee_id:
                domain.append(('employee_id', '=', int(employee_id)))
            if status:
                domain.append(('state', '=', status))
            if date_from:
                domain.append(('request_date_from', '>=', date_from))
            if date_to:
                domain.append(('request_date_to', '<=', date_to))
            
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
                    'state_label': dict(leave._fields['state'].selection).get(leave.state),
                    'name': leave.name,
                    'notes': leave.notes,
                    'create_date': leave.create_date.strftime('%Y-%m-%d %H:%M:%S') if leave.create_date else None,
                    'can_approve': leave.can_approve,
                    'can_cancel': leave.can_cancel,
                })
            
            return self._json_response(
                data={
                    'leaves': leave_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset,
                    'has_more': offset + limit < total_count
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
            
            # Validate dates
            try:
                date_from = datetime.strptime(data['request_date_from'], '%Y-%m-%d').date()
                date_to = datetime.strptime(data['request_date_to'], '%Y-%m-%d').date()
                
                if date_from > date_to:
                    return self._error_response("Start date cannot be later than end date", 400)
                    
            except ValueError:
                return self._error_response("Invalid date format. Use YYYY-MM-DD", 400)
            
            # Create leave request
            leave_vals = {
                'employee_id': data['employee_id'],
                'holiday_status_id': data['holiday_status_id'],
                'request_date_from': date_from,
                'request_date_to': date_to,
                'name': data.get('name', ''),
                'notes': data.get('notes', ''),
            }
            
            leave = request.env['hr.leave'].create(leave_vals)
            
            # Auto-submit if requested
            if data.get('auto_submit', False):
                leave.action_submit()
            
            return self._json_response(
                data={
                    'id': leave.id,
                    'employee_name': leave.employee_id.name,
                    'leave_type': leave.holiday_status_id.name,
                    'request_date_from': leave.request_date_from.strftime('%Y-%m-%d'),
                    'request_date_to': leave.request_date_to.strftime('%Y-%m-%d'),
                    'number_of_days': leave.number_of_days,
                    'state': leave.state,
                },
                message="Leave request created successfully"
            )
            
        except json.JSONDecodeError:
            return self._error_response("Invalid JSON data", 400)
        except Exception as e:
            _logger.error(f"Create leave error: {str(e)}")
            return self._error_response("Failed to create leave request", 500)
    
    @http.route('/api/leaves/<int:leave_id>/approve', type='http', auth='user', methods=['POST', 'OPTIONS'], csrf=False)
    def approve_leave(self, leave_id):
        """Approve leave request"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            leave = request.env['hr.leave'].browse(leave_id)
            
            if not leave.exists():
                return self._error_response("Leave request not found", 404)
            
            if not leave.can_approve:
                return self._error_response("You don't have permission to approve this leave", 403)
            
            leave.action_approve()
            
            return self._json_response(
                data={'id': leave.id, 'state': leave.state},
                message="Leave request approved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Approve leave error: {str(e)}")
            return self._error_response("Failed to approve leave request", 500)
    
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
                    'requires_allocation': leave_type.requires_allocation,
                    'request_unit': leave_type.request_unit,
                })
            
            return self._json_response(
                data=leave_type_data,
                message="Leave types retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Leave types error: {str(e)}")
            return self._error_response("Failed to retrieve leave types", 500)
    
    @http.route('/api/leave-balance/<int:employee_id>', type='http', auth='user', methods=['GET', 'OPTIONS'], csrf=False)
    def get_leave_balance(self, employee_id):
        """Get employee leave balance"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
        
        try:
            employee = request.env['hr.employee'].browse(employee_id)
            if not employee.exists():
                return self._error_response("Employee not found", 404)
            
            # Get leave allocations
            allocations = request.env['hr.leave.allocation'].search([
                ('employee_id', '=', employee_id),
                ('state', '=', 'validate')
            ])
            
            balance_data = []
            for allocation in allocations:
                balance_data.append({
                    'leave_type': allocation.holiday_status_id.name,
                    'leave_type_id': allocation.holiday_status_id.id,
                    'allocated_days': allocation.number_of_days,
                    'remaining_days': allocation.number_of_days - allocation.leaves_taken,
                    'used_days': allocation.leaves_taken,
                })
            
            return self._json_response(
                data=balance_data,
                message="Leave balance retrieved successfully"
            )
            
        except Exception as e:
            _logger.error(f"Leave balance error: {str(e)}")
            return self._error_response("Failed to retrieve leave balance", 500)
