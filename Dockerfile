# Stage 1: Build frontend
FROM node:20 AS frontend-build
WORKDIR /app
COPY client /app/client
RUN cd /app/client && npm install && npm run build

# Stage 2: Build backend
FROM maven:3.9.3-eclipse-temurin-17 AS backend-build
WORKDIR /app
COPY authify /app/authify
RUN chmod +x /app/authify/mvnw
RUN cd /app/authify && ./mvnw clean package -DskipTests

# Stage 3: Final runtime image
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=backend-build /app/authify/target/authify-0.0.1-SNAPSHOT.jar app.jar
COPY --from=frontend-build /app/client/build /app/static
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
