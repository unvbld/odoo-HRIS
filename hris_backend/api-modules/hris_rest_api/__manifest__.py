{
    'name': 'HRIS REST API',
    'version': '1.0.0',
    'category': 'Human Resources',
    'summary': 'REST API for HRIS Flutter Application',
    'description': """
        This module provides REST API endpoints for the HRIS Flutter application.
        It includes authentication, employee management, leave management, and other HR features.
    """,
    'author': 'Your Company',
    'website': 'https://www.yourcompany.com',
    'depends': [
        'base',
        'hr',
        'hr_holidays',
        'hr_attendance',
        'hr_payroll_community',
        'project',
    ],
    'data': [
        'security/ir.model.access.csv',
        'data/api_endpoints.xml',
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
}
