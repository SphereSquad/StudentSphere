# 🌐 StudentSphere — Student Life Management Platform

**A Centralized Platform for Academic Planning, Expense Management, Campus Activities, and Student Productivity**

<p align="center">
  <img src="https://img.shields.io/badge/Java-Backend-orange?style=for-the-badge&logo=openjdk" alt="Java"/>
  <img src="https://img.shields.io/badge/JSP-Frontend-blue?style=for-the-badge" alt="JSP"/>
  <img src="https://img.shields.io/badge/Servlet-Controller-green?style=for-the-badge" alt="Servlet"/>
  <img src="https://img.shields.io/badge/MySQL-Database-blue?style=for-the-badge&logo=mysql" alt="MySQL"/>
  <img src="https://img.shields.io/badge/Apache_Tomcat-Server-yellow?style=for-the-badge&logo=apachetomcat" alt="Tomcat"/>
</p>

## 📌 About the Project

**StudentSphere** is a student-focused web application designed to bring essential student activities together on one platform. It helps college students organize their academic tasks, manage personal expenses, discover campus events, stay informed about club announcements, and track their personal goals.

Instead of switching between different applications, students can use a personalized dashboard to manage their daily academic and personal activities in one place.

The project is developed using Java Servlets, JSP, JDBC, MySQL, and Apache Tomcat. Its modular architecture keeps the major features organized into separate functional areas, making the application easier to maintain, test, and extend.

## 🎯 Problem Statement

College students often struggle to manage assignments, deadlines, monthly spending, college events, and personal goals using separate tools. This can lead to missed deadlines, poor expense tracking, and difficulty staying updated about campus activities.

StudentSphere addresses these challenges through a centralized platform that provides organized task management, budget monitoring, event registration, community announcements, and progress tracking.

## 💡 Project Objectives

- Provide a centralized platform for student productivity.
- Simplify academic task planning and deadline management.
- Help students monitor expenses and monthly budgets.
- Make campus events easier to discover and register for.
- Provide a common space for college club announcements.
- Track weekly goals and personal progress.
- Apply DBMS, AOA, Operating Systems, and Software Engineering concepts in a practical project.
- Maintain a modular, understandable, and maintainable codebase.

## 📝 Abstract

StudentSphere is a web-based Student Life Management Platform developed to simplify the academic and personal organization of college students. The application integrates five functional modules: Study Planner and Task Manager, Expense and Budget Tracker, Campus Events and Registration, Clubs and Community Announcements, and Goals and Progress Dashboard.

The Study Planner enables students to organize assignments, set priorities, and monitor deadlines. The Expense Tracker records expenditures and compares monthly spending against a defined budget. The Campus Events module allows students to discover activities and manage registrations, while the Clubs and Community Announcements module provides access to relevant campus notices. The Goals and Progress Dashboard presents a consolidated view of tasks, budgets, goals, and upcoming activities.

The application uses Java Servlets and JSP for request processing and presentation, JDBC for database connectivity, MySQL for persistent data storage, and Apache Tomcat as the application server. Its modular design separates feature-specific components while reusing common infrastructure such as authentication and database connectivity.

The project demonstrates practical software engineering principles, relational database management, algorithmic task prioritization, and structured web application development. StudentSphere aims to provide a simple, accessible, and maintainable solution for improving student productivity and campus engagement.

**Keywords:** Student Management, Java Web Application, JSP, Servlets, JDBC, MySQL, Task Management, Expense Tracking, Campus Events, Student Productivity.

---

## 🚀 Main Features and Modules

### Module 1: Study Planner and Task Manager

- Add, edit, delete, and complete personal tasks.
- Organize tasks by subject and deadline.
- Assign priority levels to academic activities.
- View pending and completed tasks.
- Identify upcoming deadlines.
- Sort tasks by urgency and priority.

**Example:** An assignment due tomorrow can be prioritized above a task due next week.

### Module 2: Expense and Budget Tracker

- Record daily expenses.
- Categorize spending into Food, Travel, Books, Education, Shopping, and Other.
- Set monthly spending limits.
- Calculate total expenditure and remaining budget.
- Review monthly and category-wise spending summaries.

**Example:** If the monthly budget is ₹5,000 and the total expenditure is ₹3,200, the remaining budget is ₹1,800.

### Module 3: Campus Events and Registration

- Display college seminars, workshops, hackathons, and competitions.
- View event descriptions, dates, venues, and registration deadlines.
- Register for available events.
- View upcoming and registered events.
- Allow authorized administrators to manage events.

### Module 4: Clubs and Community Announcements

- Browse club announcements and campus notices.
- Organize announcements by category.
- Display information published by authorized representatives.
- Save useful announcements for later reference.
- Provide a centralized space for student communities.

### Module 5: Goals and Progress Dashboard

- Set and track weekly goals.
- View task completion statistics.
- Monitor monthly expenditure and remaining budget.
- Display upcoming registered events.
- Show recent announcements and useful summaries.
- Present progress through simple visual indicators.

The dashboard uses information from the other modules to provide a consolidated overview.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Java | Application logic and backend programming |
| Java Servlets | Request handling and controller logic |
| JSP | Dynamic web pages and presentation |
| JDBC | Communication between Java and MySQL |
| MySQL | Relational database management |
| HTML5 | Web page structure |
| CSS3 | Styling and responsive layouts |
| JavaScript | Client-side interactions and validation |
| Apache Tomcat 10 | Web application server |
| Eclipse IDE | Development environment |
| Git and GitHub | Version control and team collaboration |

**Project setup:** Traditional Eclipse Dynamic Web Project. Maven and Spring Boot are not used.

## 🏗️ Project Architecture

StudentSphere follows a modular, layered MVC-style architecture.

- **Model:** Represents application entities such as tasks, expenses, events, announcements, and goals.
- **View:** JSP pages display the application interface.
- **Controller:** Servlets process requests and coordinate application operations.
- **DAO:** Data Access Objects handle module-specific SQL queries.
- **Database:** MySQL stores application data.
- **Shared utilities:** Database connection, authentication, session management, and common helpers.

Each module maintains its own model, DAO, Servlet, service, and view components wherever applicable. Common infrastructure is reused to avoid duplication.

## 📂 Project Structure

```text
StudentSphere/
│
├── src/main/java/
│   └── com/studentsphere/
│       ├── auth/
│       ├── config/
│       ├── common/
│       ├── studyplanner/
│       │   ├── model/
│       │   ├── dao/
│       │   ├── servlet/
│       │   └── service/
│       ├── expensetracker/
│       │   ├── model/
│       │   ├── dao/
│       │   ├── servlet/
│       │   └── service/
│       ├── events/
│       │   ├── model/
│       │   ├── dao/
│       │   ├── servlet/
│       │   └── service/
│       ├── clubs/
│       │   ├── model/
│       │   ├── dao/
│       │   ├── servlet/
│       │   └── service/
│       ├── goals/
│       │   ├── model/
│       │   ├── dao/
│       │   └── servlet/
│       └── dashboard/
│
├── src/main/webapp/
│   ├── assets/
│   │   ├── css/
│   │   ├── js/
│   │   └── images/
│   ├── views/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── study/
│   │   ├── expense/
│   │   ├── events/
│   │   ├── announcements/
│   │   └── goals/
│   ├── WEB-INF/
│   │   └── web.xml
│   ├── index.jsp
│   ├── login.jsp
│   └── register.jsp
│
├── database.sql
├── README.md
└── .gitignore
```

*Note: This is the logical project structure. Folder and package names in the documentation should be aligned with the actual Eclipse repository.*

---

# 📅 12-Week Development Timeline

## Week 1 — Project Planning and Requirement Analysis

**Abstract:** The first week focuses on understanding the problem, defining requirements, identifying the five modules, and planning the application architecture.

- **Study Planner:** Identified requirements for tasks, subjects, priorities, and deadlines.
- **Expense Tracker:** Defined expense categories, monthly budgets, and spending summaries.
- **Campus Events:** Identified event discovery, registration, and administration requirements.
- **Clubs and Announcements:** Defined announcement categories, publishing permissions, and saved notices.
- **Goals and Dashboard:** Planned weekly goals and consolidated progress indicators.

**Overall outcome:** Project scope, problem statement, objectives, and module responsibilities were defined.

## Week 2 — System Design and Database Planning

**Abstract:** The second week focuses on application design, relational database planning, and defining the responsibilities of each module.

- **Study Planner:** Designed the task entity, task attributes, and relationships with users.
- **Expense Tracker:** Planned expense records, budget storage, and category-wise calculations.
- **Campus Events:** Designed event and registration entities with seat limits and deadlines.
- **Clubs and Announcements:** Planned announcement records, categories, and saved announcement relationships.
- **Goals and Dashboard:** Designed goals and identified the data required for progress summaries.

**Overall outcome:** Database planning, module boundaries, and application flow were established.

## Week 3 — Project Setup and Shared Infrastructure

**Abstract:** The third week focuses on setting up the Java web application and creating common infrastructure for all modules.

- **Study Planner:** Created the package structure and planned task-related Servlets and DAOs.
- **Expense Tracker:** Created dedicated packages for expense models, database access, and controllers.
- **Campus Events:** Established event module packages and planned registration endpoints.
- **Clubs and Announcements:** Created the module structure and identified publishing operations.
- **Goals and Dashboard:** Established the dashboard structure and identified shared data dependencies.

**Overall outcome:** Eclipse project setup, Tomcat configuration, MySQL connectivity, and module organization were addressed.

## Week 4 — Authentication and Core Module Development

**Abstract:** The fourth week focuses on account access, session management, and the first implementation of module-specific functionality.

- **Study Planner:** Implemented or prepared task creation and task-list functionality.
- **Expense Tracker:** Implemented or prepared expense entry forms and database operations.
- **Campus Events:** Started event listing and event-detail functionality.
- **Clubs and Announcements:** Started announcement listing and category-based display.
- **Goals and Dashboard:** Established the dashboard page and initial layout.

**Overall outcome:** Authentication and the initial functional pages were integrated with the application structure.

## Week 5 — Study Planner Implementation

**Abstract:** The fifth week concentrates on implementing academic task management and establishing the task workflow.

- **Study Planner:** Developed task creation, editing, deletion, completion status, deadlines, and priority handling.
- **Expense Tracker:** Refined expense entry validation and category selection.
- **Campus Events:** Developed event details and upcoming-event display.
- **Clubs and Announcements:** Improved announcement cards and category navigation.
- **Goals and Dashboard:** Connected the initial dashboard with task summary information.

**Overall outcome:** Task management functionality and the first dashboard integration were developed.

## Week 6 — Expense and Budget Management

**Abstract:** The sixth week focuses on expense recording, budget calculations, and improving financial summaries.

- **Study Planner:** Refined task filtering, sorting, and completion tracking.
- **Expense Tracker:** Implemented or refined expense CRUD operations, monthly budgets, total spending, and remaining-budget calculations.
- **Campus Events:** Improved event listing and event registration form handling.
- **Clubs and Announcements:** Refined announcement display and saved-notice functionality.
- **Goals and Dashboard:** Integrated or prepared monthly spending and budget indicators.

**Overall outcome:** Expense management and the interaction between stored financial data and dashboard summaries were addressed.

## Week 7 — Campus Events and Registration

**Abstract:** The seventh week focuses on event discovery, registration workflows, and event administration.

- **Study Planner:** Refined deadline handling and task priority ordering.
- **Expense Tracker:** Improved monthly summaries and category-wise calculations.
- **Campus Events:** Implemented or refined event listings, registration, cancellation, deadlines, and seat availability.
- **Clubs and Announcements:** Organized notices related to seminars, competitions, and campus activities.
- **Goals and Dashboard:** Connected upcoming registered events with the dashboard.

**Overall outcome:** Campus event workflows and their integration with the student dashboard were developed.

## Week 8 — Clubs and Community Announcements

**Abstract:** The eighth week focuses on providing a centralized space for club communications and campus notices.

- **Study Planner:** Reviewed task workflows and corrected identified issues.
- **Expense Tracker:** Tested expense editing, deletion, and budget calculations.
- **Campus Events:** Refined event administration and registration validation.
- **Clubs and Announcements:** Developed announcement management, categories, role-based publishing, and saved announcements.
- **Goals and Dashboard:** Integrated recent announcements into the dashboard where applicable.

**Overall outcome:** Community announcements and related event information were connected with the main application.

## Week 9 — Goals and Dashboard Integration

**Abstract:** The ninth week focuses on connecting module data to provide a personalized overview of student progress.

- **Study Planner:** Provided task completion counts and pending-task summaries.
- **Expense Tracker:** Provided monthly expenditure and remaining-budget data.
- **Campus Events:** Provided upcoming events and registration summaries.
- **Clubs and Announcements:** Provided recent notices and saved announcement information.
- **Goals and Dashboard:** Developed weekly goal tracking, progress indicators, and combined dashboard summaries.

**Overall outcome:** The dashboard was connected to the principal modules to consolidate student activity information.

## Week 10 — User Interface and Functional Testing

**Abstract:** The tenth week focuses on improving usability, maintaining a consistent interface, and testing the main application workflows.

- **Study Planner:** Tested task creation, editing, deletion, completion, and filtering.
- **Expense Tracker:** Tested expense records, budget calculations, and summary displays.
- **Campus Events:** Tested registration, cancellation, deadlines, and seat-limit handling.
- **Clubs and Announcements:** Tested announcement browsing, saving, and publishing permissions.
- **Goals and Dashboard:** Tested progress calculations, summary cards, navigation, and page consistency.

**Overall outcome:** Module-wise testing and user-interface improvements were carried out.

## Week 11 — Integration, Validation, and Bug Fixing

**Abstract:** The eleventh week focuses on integration testing, database consistency, access control, and resolving issues discovered during testing.

- **Study Planner:** Corrected identified task-handling and validation issues.
- **Expense Tracker:** Checked calculations, invalid inputs, and user-specific expense access.
- **Campus Events:** Verified duplicate-registration prevention, availability checks, and event permissions.
- **Clubs and Announcements:** Checked authorized publishing, saved records, and user access.
- **Goals and Dashboard:** Verified summaries against their source data and corrected integration issues.

**Overall outcome:** Cross-module integration, validation, and application stability were reviewed.

## Week 12 — Final Testing and Documentation

**Abstract:** The final week focuses on preparing the application for demonstration, completing documentation, and reviewing the deliverables.

- **Study Planner:** Reviewed the final task-management workflow and priority algorithm explanation.
- **Expense Tracker:** Reviewed budget calculations and financial summary functionality.
- **Campus Events:** Reviewed event management and registration workflows.
- **Clubs and Announcements:** Reviewed announcement publishing, browsing, and permissions.
- **Goals and Dashboard:** Reviewed the consolidated dashboard and progress summaries.

**Overall outcome:** Final testing, database documentation, project report preparation, presentation preparation, and GitHub repository review were completed.

*The weekly timeline describes the intended 12-week development progression. Update any activity that differs from the work actually completed by the team.*

---

# 👥 Team Members and Responsibilities

The project is divided among four team members to support parallel development, module ownership, and coordinated integration.

## Member 1 — Project Integration and Dashboard

**Primary responsibility:** Common application infrastructure, integration, and Goals and Progress Dashboard.

Responsibilities:

- Maintain the overall application structure and module organization.
- Coordinate shared database connectivity and authentication integration.
- Develop and maintain dashboard pages and dashboard-related Servlet/service logic.
- Connect task, expense, event, and announcement summaries to the dashboard.
- Coordinate code reviews and resolve cross-module integration issues.
- Maintain the GitHub repository and help integrate team contributions.
- Verify that shared components remain consistent across the application.

**Key learning areas:** MVC architecture, modular development, session management, data integration, and version control.

## Member 2 — Study Planner and Task Manager

**Primary responsibility:** Study Planner module.

Responsibilities:

- Develop task-related model classes and DAO operations.
- Implement task creation, editing, deletion, and completion.
- Handle subjects, deadlines, priority levels, and task status.
- Implement task filtering and sorting.
- Validate task inputs and protect student-specific task data.
- Provide task statistics for the dashboard.
- Test task-related operations and correct module-specific issues.

**Key learning areas:** Java programming, CRUD operations, JDBC, algorithmic prioritization, and SQL queries.

## Member 3 — Expense and Budget Tracker

**Primary responsibility:** Expense Tracker module.

Responsibilities:

- Develop expense model classes and DAO operations.
- Implement expense creation, editing, deletion, and category selection.
- Store and retrieve monthly budget information.
- Calculate total spending and remaining budget.
- Develop monthly and category-wise summaries.
- Validate amounts and dates.
- Ensure that students can access only their own expense records.
- Test budget calculations and database operations.

**Key learning areas:** JDBC, relational database design, aggregation queries, validation, and financial calculations.

## Member 4 — Campus Events and Clubs & Announcements

**Primary responsibility:** Campus Events and Community Announcements modules.

Responsibilities:

- Develop event and announcement model classes and DAO operations.
- Implement event listings, event details, and registration workflows.
- Handle registration deadlines, seat availability, and duplicate registrations.
- Develop announcement listings, categories, and saved announcements.
- Implement authorized event and announcement management.
- Validate permissions for administrative and club publishing operations.
- Test event registration and announcement workflows.
- Provide relevant data for dashboard summaries.

**Key learning areas:** Servlet request handling, relational relationships, authorization, event workflows, and module integration.

### Shared Team Responsibilities

All members contribute to code review, database consistency, integration testing, documentation, debugging, and project demonstrations.

Module ownership identifies the primary developer; it does not prevent other members from reviewing or contributing to that module.

---

# 🧪 Testing and Validation

The following areas should be verified before the final demonstration:

- Registration, login, logout, and session handling.
- Correct creation, modification, and deletion of records.
- Data persistence after restarting the application.
- User-specific access to tasks, expenses, goals, and registrations.
- Correct budget and progress calculations.
- Event registration deadlines and availability checks.
- Authorized access to event and announcement management.
- Consistent navigation between modules.
- Proper database connectivity and error messages.
- Successful deployment on the configured Apache Tomcat server.

## 🔐 Security Considerations

- Use prepared statements for database operations.
- Store passwords as secure password hashes.
- Validate input on the server side.
- Enforce authentication and authorization in Servlets.
- Avoid exposing database credentials in public source code.
- Restrict personal data to the authorized student.
- Validate event registration and seat availability on the server.

---



# 🔮 Future Enhancements

Potential future improvements include:

- Email reminders for upcoming deadlines.
- Calendar integration for tasks and events.
- Advanced progress analytics.
- Exportable expense summaries.
- Improved mobile responsiveness.
- Notifications for important campus announcements.
- Additional reporting and administrative tools.

These are future possibilities and should not be interpreted as completed features unless implemented.

---

# 📎 Project Resources and Documentation

Use the following section to access project documentation, presentations, research material, and demonstration videos.

| Resource | Link |
|---|---|
| GitHub Repository | [StudentSphere Source Code](https://github.com/Kashishjangid05/StudentSphere) |
| Project Report | [Add Project Report Link](REPORT_LINK) |
| Research Paper | [Add Research Paper Link](RESEARCH_PAPER_LINK) |
| Project Presentation (PPT) | [Add PPT Link](PPT_LINK) |
| Project Demonstration Video | [Add Video Link](VIDEO_LINK) |
| ER Diagram | [Add ER Diagram Link](ER_DIAGRAM_LINK) |
| Database SQL Script | [View database.sql in Repository](https://github.com/Kashishjangid05/StudentSphere/blob/main/database.sql) |
| Setup and Installation Guide | [Add Setup Guide Link](SETUP_GUIDE_LINK) |

**Note:** Replace the placeholder links with actual URLs before publishing the final README. Upload documents to the repository's `docs/` folder or use shareable links from an appropriate document-hosting service. Do not include private credentials or confidential student data.

---

# ▶️ Installation and Setup

### Prerequisites

- Java Development Kit compatible with the configured Tomcat version.
- Eclipse IDE with web development support.
- Apache Tomcat 10.
- MySQL Server.
- MySQL JDBC driver compatible with the project.
- Git for version control.

### Setup Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/Kashishjangid05/StudentSphere.git
   ```

2. Import the project into Eclipse using the appropriate existing Dynamic Web Project structure.

3. Create the MySQL database and execute the provided `database.sql` script.

4. Configure the database connection settings in the project's shared connection utility.

5. Ensure the compatible MySQL JDBC driver is available to the application.

6. Configure Apache Tomcat in Eclipse.

7. Run the project on the server and open the application through its local Tomcat URL.

*The exact database settings, SQL filename, and deployment instructions should match the files actually present in the repository.*

---

# 🤝 Contribution and Version Control

StudentSphere is developed collaboratively by a team of four.

- Keep module-specific changes within the relevant packages and folders.
- Test changes before committing.
- Use descriptive commit messages.
- Pull the latest repository changes before beginning new work.
- Resolve merge conflicts carefully.
- Avoid committing generated files, credentials, or unrelated workspace files.
- Coordinate changes to shared database and authentication components.

### Example Git Workflow

```bash
git pull origin main
git add .
git commit -m "Update module functionality"
git push origin main
```

For team members working on shared branches, coordinate commits and merges to avoid overwriting each other's work.

---

# 📄 License

This project was developed for academic purposes as part of a college project. Add an appropriate open-source license if the team decides to distribute the source code under specific reuse terms.

---

<p align="center">
  <b>StudentSphere — Plan Better. Spend Smarter. Stay Connected. Grow Together.</b>
</p>

<p align="center">
  Built with Java, JSP, Servlets, JDBC, MySQL, and teamwork.
</p>
