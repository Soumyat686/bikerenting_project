FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

COPY bikeshare_model/ bikeshare_model/
COPY bike_sharing_api/ bike_sharing_api/
COPY tests/ tests/
COPY MANIFEST.in mypy.ini pyproject.toml setup.py ./

# Copy requirements directory first
COPY requirements/ requirements/

# Install build dependencies and all requirements
RUN apt-get update && apt-get install -y --no-install-recommends gcc build-essential \
    && pip install --no-cache-dir -e ".[api]" \
    && pip install --no-cache-dir fastapi uvicorn pydantic-settings \
    && apt-get remove -y gcc build-essential \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



# Create VERSION file if it doesn't exist
RUN if [ ! -f bikeshare_model/VERSION ]; then echo "0.1.0" > bikeshare_model/VERSION; fi

# Create a non-root user to run the application
RUN useradd -m appuser
USER appuser

# Expose the API port
EXPOSE 8001

# Command to run the application
CMD ["uvicorn", "bike_sharing_api.app.main:app", "--host", "0.0.0.0", "--port", "8001"]