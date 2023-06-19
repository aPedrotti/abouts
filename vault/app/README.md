# App

Python web app that interacts with Hashicorp Vault Server and a Databse

## Capabilities

- Button 1 - Get a database credentials key-value from a Hashicorp Vault server;
- Button 2 - Print the credential that it got;
- Button 3 - Try access to database, if fails gets credentials from hashicorp vault server and then, with these credentials, creates a database called `my-app`, create a table called customers with columns: CPF (as primary key), name, email and country
- Button 4 - Try access to database, if fails gets credentials from hashicorp vault server and then insert 100 dummy data to table `customers`.
- Button 5 - Try access to database, if fails gets credentials from hashicorp vault server and then select data from this database and table.
