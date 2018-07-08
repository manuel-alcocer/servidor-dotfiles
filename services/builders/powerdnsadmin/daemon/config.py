import os
from os import environ
basedir = os.path.abspath(os.path.dirname(__file__))

# BASIC APP CONFIG
WTF_CSRF_ENABLED = True
SECRET_KEY = environ['PDNSADMIN_SECRET_KEY']
BIND_ADDRESS = '0.0.0.0'
PORT = 9191
LOGIN_TITLE = "PDNS"

# TIMEOUT - for large zones
TIMEOUT = 10

# LOG CONFIG
LOG_LEVEL = 'DEBUG'
LOG_FILE = 'logfile.log'
# For Docker, leave empty string
#LOG_FILE = ''

# Upload
UPLOAD_DIR = os.path.join(basedir, 'upload')

# DATABASE CONFIG
#You'll need MySQL-python
SQLA_DB_USER = environ['SQLA_DB_USER']
SQLA_DB_PASSWORD = environ['SQLA_DB_PASSWORD']
SQLA_DB_HOST = environ['SQLA_DB_HOST']
SQLA_DB_NAME = environ['SQLA_DB_NAME']

#MySQL
SQLALCHEMY_DATABASE_URI = 'mysql://'+SQLA_DB_USER+':'\
    +SQLA_DB_PASSWORD+'@'+SQLA_DB_HOST+'/'+SQLA_DB_NAME

# LDAP CONFIG
LDAP_ENABLED = False

# Github Oauth
GITHUB_OAUTH_ENABLE = False

# Google OAuth
GOOGLE_OAUTH_ENABLE = False

# SAML Authnetication
SAML_ENABLED = False

#Default Auth
BASIC_ENABLED = True
SIGNUP_ENABLED = True

# POWERDNS CONFIG
PDNS_HOST = environ['PDNS_HOST']
PDNS_PORT = environ['PDNS_WEB_PORT']
PDNS_STATS_URL = 'http://%s:%s/' %(PDNS_HOST, PDNS_PORT)
PDNS_API_KEY = environ['PDNS_API_KEY']
PDNS_VERSION = '4.1.1'

# RECORDS ALLOWED TO EDIT
RECORDS_ALLOW_EDIT = ['SOA', 'A', 'AAAA', 'CAA', 'CNAME', 'MX', 'PTR', 'SPF', 'SRV', 'TXT', 'LOC', 'NS', 'PTR']
FORWARD_RECORDS_ALLOW_EDIT = ['A', 'AAAA', 'CAA', 'CNAME', 'MX', 'PTR', 'SPF', 'SRV', 'TXT', 'LOC' 'NS']
REVERSE_RECORDS_ALLOW_EDIT = ['SOA', 'TXT', 'LOC', 'NS', 'PTR']

# ALLOW DNSSEC CHANGES FOR ADMINS ONLY
DNSSEC_ADMINS_ONLY = False

# EXPERIMENTAL FEATURES
PRETTY_IPV6_PTR = False

# Domain updates in background, for big installations
BG_DOMAIN_UPDATES = False
