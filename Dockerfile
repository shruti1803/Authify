# -----------------------------
# Stage 1: Build backend
# -----------------------------
FROM maven:3.9.11-eclipse-temurin-21 AS backend-build

WORKDIR /app

# Copy backend source
COPY authify /app/authify

# Make Maven wrapper executable
RUN chmod +x /app/authify/mvnw

# Build backend (skip tests to save time)
RUN cd /app/authify && ./mvnw clean package -DskipTests

# -----------------------------
# Stage 2: Build frontend
# -----------------------------
FROM node:20 AS frontend-build

WORKDIR /app

# Copy frontend source
COPY client /app/client

# Install dependencies and build frontend
RUN cd /app/client && npm install && npm run build

# -----------------------------
# Stage 3: Final runtime image
# -----------------------------
FROM eclipse-temurin:21-jdk AS runtime

WORKDIR /app

# Copy backend jar
COPY --from=backend-build /app/authify/target/*.jar /app/authify.jar

# Copy frontend build
COPY --from=frontend-build /app/client/dist /app/client/dist

# Expose the port your Spring Boot app runs on
EXPOSE 8080

# Run the backend
ENTRYPOINT ["java", "-jar", "/app/authify.jar"]
