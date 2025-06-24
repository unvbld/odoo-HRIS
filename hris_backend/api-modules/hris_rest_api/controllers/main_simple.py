import json
from odoo import http
from odoo.http import request

class HRISRestAPI(http.Controller):
    
    @http.route('/api/health', type='http', auth='none', methods=['GET'], csrf=False)
    def health_check(self):
        """Simple health check endpoint"""
        return json.dumps({
            'status': 'ok',
            'message': 'HRIS REST API is running'
        })
