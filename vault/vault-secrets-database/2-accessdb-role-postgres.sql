--'name' doest accept single quote. Dont know why
CREATE USER "{{name}}" WITH ENCRYPTED PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO "{{name}}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "{{name}}";
GRANT ALL ON SCHEMA public TO "{{name}}";