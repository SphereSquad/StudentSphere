# StudentSphere — Student Life Management Platform

StudentSphere is a Java-based web application designed to help students manage their academic tasks, expenses, campus events, and college communities through one platform.

## Project Objectives

- Provide a common platform for student activities.
- Keep different features organized into separate modules.
- Make the application easy to maintain and extend.
- Allow team members to develop different modules independently.

## Technology Stack

- **Language:** Java
- **Backend:** Java Servlets
- **Frontend:** JSP, HTML, CSS and JavaScript
- **Web Server:** Apache Tomcat 10
- **Database:** MySQL
- **IDE:** Eclipse
- **Version Control:** Git and GitHub

## Project Modules

### 1. Authentication
Login and registration functionality for users.

### 2. Student Dashboard
A common dashboard that provides access to the application's modules.

### 3. Study Planner
Helps students organize study tasks, deadlines, and schedules.

### 4. Expense Tracker
Helps students record expenses and manage budgets.

### 5. Campus Events
Displays campus events such as hackathons, seminars, and workshops.

### 6. Clubs and Announcements
Provides information about student clubs and their announcements.

## Project Structure

- `src/main/java/` — Java packages, Servlets, and Java classes.
- `src/main/webapp/` — JSP pages and web resources.
- `src/main/webapp/assets/css/` — Stylesheets.
- `src/main/webapp/assets/js/` — JavaScript files.
- `src/main/webapp/assets/images/` — Images and other visual assets.
- `src/main/webapp/modules/` — Separate JSP folders for individual modules.
- `src/main/webapp/WEB-INF/` — Web application configuration and protected resources.
- `database.sql` — Database creation and setup script.

## Requirements

- A compatible JDK.
- Eclipse IDE with Web Tools support.
- Apache Tomcat 10.
- MySQL Server.
- MySQL Connector/J.
- GitHub Desktop (for team collaboration).

## Setup Instructions

1. Clone or download the StudentSphere repository.
2. Import the project into Eclipse using **File → Import → General → Existing Projects into Workspace**.
3. Configure the installed JDK and Apache Tomcat 10.
4. Create the MySQL database using the provided `database.sql` script.
5. Add MySQL Connector/J to the project's Java Build Path if required.
6. Configure the database connection using your local database settings.
7. Run the project on Apache Tomcat.

## Team Collaboration

Each team member is responsible for assigned modules. Module-specific Java classes, JSP pages, and stylesheets should remain organized separately.

All members should follow the common project structure and coordinate changes to shared files. GitHub is used to share code, review changes, and integrate completed modules.

## Security Notes

- Do not upload database passwords or other private credentials to GitHub.
- Store passwords securely using appropriate password hashing.
- Ensure users can access only the data they are authorized to view.

## Project Status

The project structure and common foundation are being prepared. Individual modules will be developed and integrated incrementally.

## Academic Project

Developed as a group semester project to apply Java web development, database management, software design, and version control concepts.