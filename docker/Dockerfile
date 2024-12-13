# database/docker/Dockerfile

FROM postgres:latest

# Set environment variables (optional, already set in docker-compose.yml)
ENV POSTGRES_USER=mendes
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=db

# Copy initialization scripts into the container
COPY ./docker/init /docker-entrypoint-initdb.d/

# Expose the PostgreSQL port
EXPOSE 5432
