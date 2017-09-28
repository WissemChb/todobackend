from base import *
import os


# Intalled APPs
INSTALLED_APPS += ('django_nose',)
TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'
TEST_OUTPUT_DIR = os.environ.get('TEST_OUTPUT_DIR','.')
NOSE_ARGS = [
    '--rednose',
    '--force-color',
    '--verbosity=2',
    '--nologcapture',
    '--with-coverage',
    '--cover-package=todo',
    '--with-spec',
    '--with-xunit',
    '--xunit-file=%s/unittest.xml'% TEST_OUTPUT_DIR,
    '--cover-xml',
    '--cover-xml-file=%s/coverage.xml'% TEST_OUTPUT_DIR,
]

# Database
# https://docs.djangoproject.com/en/1.11/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('MYSQL_DATABASE', 'todobackend'),
        'USER': os.environ.get('MYSQL_USER', 'wissem'),
        'PASSWORD': os.environ.get('MYSQL_PASSWORD', 'wissem'),
        'HOST': os.environ.get('MYSQL_HOST', 'localhost'),
        'PORT': os.environ.get('MYSQL_PORT', '3306'),
    }
}