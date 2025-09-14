# Stage 1: Build backend
FROM maven:3.9.2-eclipse-temurin-17 AS backend-build
WORKDIR /app
COPY authify/pom.xml authify/mvnw authify/.mvn /app/authify/
COPY authify/src /app/authify/src
RUN chmod +x authify/mvnw
RUN cd authify && ./mvnw clean package -DskipTests

# Stage 2: Build frontend
FROM node:20 AS frontend-build
WORKDIR /app
COPY client/package.json client/package-lock.json /app/client/
RUN cd client && npm install
COPY client /app/client
RUN cd client && npm run build

# Stage 3: Combine and run backend
FROM eclipse-temurin:17-jdk
WORKDIR /app
# Copy backend JAR
COPY --from=backend-build /app/authify/target/*.jar app.jar
# Copy frontend build to backend resources (so Spring serves it)
COPY --from=frontend-build /app/client/build /app/authify/src/main/resources/static
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
