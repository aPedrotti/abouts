# Use the official Python base image
FROM python:3.10-alpine

# Set the working directory in the container
WORKDIR /app

# Create a non-root user
RUN useradd --create-home appuser
USER appuser

# Copy the requirements file
COPY --chown=appuser:appuser requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY --chown=appuser:appuser app.py .

# Expose port 5000 for the Flask app
EXPOSE 5000

# Set the entrypoint command
CMD ["python", "app.py"]