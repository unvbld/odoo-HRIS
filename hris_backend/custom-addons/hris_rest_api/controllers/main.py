import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class HRISRestAPI(http.Controller):
    
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
    
    @http.route('/api/health', type='http', auth='none', methods=['GET', 'OPTIONS'], csrf=False)
    def health_check(self):
        """Health check endpoint"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
            
        return self._json_response(
            data={'status': 'healthy', 'service': 'HRIS REST API'},
            message="API is running successfully"
        )
    
    @http.route('/api/version', type='http', auth='none', methods=['GET', 'OPTIONS'], csrf=False)
    def api_version(self):
        """API version endpoint"""
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=self._cors_headers())
            
        return self._json_response(
            data={'version': '1.0.0', 'api_name': 'HRIS REST API'},
            message="API version information"
        )
