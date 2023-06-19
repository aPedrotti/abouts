from flask import Flask, render_template, request
import os
import hvac
import psycopg2
import pymysql

app = Flask(__name__)

# Global variables to store the credentials
credentials = None


def authenticate_vault():
    app_role_path = os.environ.get('VAULT_APP_ROLE_PATH')
    client_id = os.environ.get('VAULT_APP_ROLE_CLIENT_ID')
    secret_key = os.environ.get('VAULT_APP_ROLE_SECRET_KEY')

    if not app_role_path or not client_id or not secret_key:
        return None

    # Create a client and authenticate with AppRole credentials
    client = hvac.Client(url='https://your-vault-server.com')

    try:
        # Generate the AppRole login request
        response = client.auth_approle(
            role_id=client_id,
            secret_id=secret_key,
            mount_point=app_role_path
        )
        if response.status_code == 200:
            client.token = response.json()['auth']['client_token']
            return client
        else:
            return None
    except hvac.exceptions.VaultDown as e:
        print(f"Failed to connect to Hashicorp Vault server: {str(e)}")
        return None

def connect_to_database(credentials):
    db_type = credentials['db_type']

    if db_type == 'postgresql':
        try:
            conn = psycopg2.connect(
                host=credentials['host'],
                port=credentials['port'],
                dbname=credentials['dbname'],
                user=credentials['username'],
                password=credentials['password']
            )
            return conn
        except psycopg2.Error as e:
            print(f"Failed to connect to PostgreSQL database: {str(e)}")
            return None

    elif db_type == 'mysql':
        try:
            conn = pymysql.connect(
                host=credentials['host'],
                port=credentials['port'],
                db=credentials['dbname'],
                user=credentials['username'],
                password=credentials['password']
            )
            return conn
        except pymysql.Error as e:
            print(f"Failed to connect to MySQL database: {str(e)}")
            return None

    else:
        print(f"Unsupported database type: {db_type}")
        return None
    
@app.route('/')
def index():
    return render_template('index.html')


@app.route('/get_credentials')
def get_credentials():
    global credentials

    # Authenticate with Hashicorp Vault
    client = authenticate_vault()

    if client:
        # Retrieve the database credentials from Hashicorp Vault
        secret = client.secrets.kv.v2.read_secret_version(
            path='your/path/to/credentials'
        )
        if 'data' in secret and 'data' in secret['data']:
            credentials = secret['data']['data']
            return 'Credentials obtained successfully'
        else:
            return 'Failed to get credentials'
    else:
        return 'Failed to authenticate with Hashicorp Vault'


# The remaining routes and functionality remain the same

@app.route('/print_credentials')
def print_credentials():
    if credentials:
        return str(credentials)
    else:
        return 'No credentials available'


@app.route('/create_database')
def create_database():
    if not credentials:
        return 'No credentials available'

    # Connect to the database using the obtained credentials
    # Assuming you have a function `connect_to_database()` that takes the credentials as input
    db_connection = connect_to_database(credentials)

    if db_connection:
        # Create the 'my-app' database and the 'customers' table
        query = "CREATE DATABASE my_app;"
        query += "USE my_app;"
        query += "CREATE TABLE customers (CPF INT PRIMARY KEY, name VARCHAR(255), email VARCHAR(255), country VARCHAR(255));"

        try:
            # Execute the query
            db_connection.execute(query)
            return 'Database and table created successfully'
        except:
            return 'Failed to create database and table'
    else:
        return 'Failed to connect to the database'

@app.route('/insert_dummy_data')
def insert_dummy_data():
    if not credentials:
        return 'No credentials available'

    # Connect to the database using the obtained credentials
    db_connection = connect_to_database(credentials)

    if db_connection:
        # Insert 100 dummy records into the 'customers' table
        query = "USE my_app;"
        query += "INSERT INTO customers (CPF, name, email, country) VALUES "

        for i in range(100):
            query += f"({i}, 'Customer {i}', 'customer{i}@example.com', 'Country {i}'),"

        query = query.rstrip(',') + ";"  # Remove the trailing comma

        try:
            # Execute the query
            db_connection.execute(query)
            return 'Dummy data inserted successfully'
        except:
            return 'Failed to insert dummy data'
    else:
        return 'Failed to connect to the database'


@app.route('/select_data')
def select_data():
    if not credentials:
        return 'No credentials available'

    # Connect to the database using the obtained credentials
    db_connection = connect_to_database(credentials)

    if db_connection:
        # Select data from the 'customers' table
        query = "USE my_app;"
        query += "SELECT * FROM customers;"

        try:
            # Execute the query
            result = db_connection.execute(query)
            data = result.fetchall()
            return str(data)
        except:
            return 'Failed to select data'
    else:
        return 'Failed to connect to the database'


if __name__ == '__main__':
    app.run()