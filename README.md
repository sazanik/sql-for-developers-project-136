# Educational Platform Database

[![Actions Status](https://github.com/sazanik/sql-for-developers-project-136/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/sazanik/sql-for-developers-project-136/actions)

## Project Description

This project provides a comprehensive PostgreSQL database schema for an educational platform. The database is designed to support a complete online learning environment with features including:

- Course and program management
- User registration and role-based access control
- Enrollment and payment processing
- Learning progress tracking
- Interactive learning components (quizzes, exercises, discussions)
- Certificate issuance
- Blog functionality

The schema utilizes modern PostgreSQL features like JSONB for flexible content storage in quizzes and discussions, ENUMs for status fields, and includes comprehensive indexing for performance optimization.

## Database Schema Overview

### Core Educational Content

- **Courses**: Collections of lessons with title and description
- **Modules**: Groups of courses that form a cohesive learning unit
- **Programs**: Complete educational offerings with pricing and type information (certificate, degree, short_course)
- **Lessons**: Individual learning units with content, videos, and position in a course

### User Management

- **Users**: Student, teacher, and admin accounts with authentication information
- **Teaching Groups**: Groups that teachers can be assigned to

### Enrollment and Progress

- **Enrollments**: Tracks user registration in programs with status tracking (active, pending, cancelled, completed)
- **Program Completions**: Records user progress through programs with start and end dates
- **Certificates**: Issued upon successful program completion

### Financial Management

- **Payments**: Tracks payment status (pending, paid, failed, refunded), amount, and dates for enrollments

### Learning Components

- **Quizzes**: Interactive assessments linked to lessons, with content stored in JSONB format
- **Exercises**: Practical assignments linked to lessons
- **Discussions**: Threaded conversations about lesson content, with structure stored in JSONB format

### Additional Features

- **Blog**: Platform for publishing educational content and announcements with moderation workflow

## Entity Relationship Diagram

The following diagram illustrates the relationships between tables in the database:

```
+---------------+     +---------------+     +---------------+
|               |     |               |     |               |
|     Users     +---->+  Enrollments  +<----+   Programs    |
|               |     |               |     |               |
+-------+-------+     +-------+-------+     +-------+-------+
    ^   |                     |                     ^
    |   |                     |                     |
    |   |                     v                     |
    |   |             +---------------+     +-------+-------+
    |   |             |               |     |               |
    |   |             |   Payments    |     |   Modules_    |
    |   |             |               |     |   Programs    |
    |   |             +---------------+     |   (Junction)  |
    |   |                                   |               |
    |   v                                   +-------+-------+
+---------------+                                   ^
|               |                                   |
|   Teaching    |                                   v
|    Groups     |                           +---------------+     +---------------+
|               |                           |               |     |               |
+---------------+                           |    Modules    +<--->+   Courses_    |
                                            |               |     |   Modules     |
                                            +-------+-------+     |   (Junction)  |
                                                    ^             |               |
                                                    |             +-------+-------+
                                                    |                     ^
                                                    |                     |
                                                    |                     v
                                                    |             +---------------+
                                                    |             |               |
                                                    |             |    Courses    |
                                                    |             |               |
                                                    |             +-------+-------+
                                                    |                     |
                                                    |                     |
                                                    |                     v
                                                    |             +---------------+
                                                    |             |               |
+---------------+     +---------------+             |             |    Lessons    |
|               |     |               |             |             |               |
|     Blog      +<----+     Users     +------------>+             +-------+-------+
|               |     |               |             |                     |
+---------------+     +-------+-------+             |                     |
                              ^                     |                     +------------+
                              |                     |                     |            |
                              |                     |                     v            v
                      +-------+-------+     +-------v-------+     +---------------+   +---------------+
                      |               |     |               |     |               |   |               |
                      | Certificates  +<----+   Program_    |     |    Quizzes    |   |   Exercises   |
                      |               |     |  Completions  |     |               |   |               |
                      +---------------+     +---------------+     +---------------+   +---------------+
                                                                                      |
                                                                                      |
                                                                                      v
                                                                              +---------------+
                                                                              |               |
                                                                              |  Discussions  |
                                                                              |               |
                                                                              +---------------+
```

The diagram shows the following key relationships:
- Users can enroll in Programs through Enrollments (many-to-many relationship)
- Payments are linked to Enrollments (one-to-many relationship)
- Programs are linked to Modules through the Modules_Programs junction table (many-to-many relationship)
- Modules are linked to Courses through the Courses_Modules junction table (many-to-many relationship)
- Courses contain Lessons (one-to-many relationship)
- Lessons can have Quizzes, Exercises, and Discussions (one-to-many relationships)
- Users can complete Programs through Program_Completions (many-to-many relationship)
- Certificates are issued to Users for specific Programs (many-to-many relationship)
- Users can create Blog posts (one-to-many relationship)
- Users can be assigned to Teaching Groups (many-to-one relationship)

## Database Features

### Soft Delete

All tables include an `is_deleted` boolean column to support soft deletion, allowing for data recovery and maintaining referential integrity.

### Automatic Timestamps

All tables include:
- `created_at` timestamp that is set automatically on record creation
- `updated_at` timestamp that is automatically updated when a record is modified using a trigger function

### Data Validation

The schema includes various constraints:
- CHECK constraints for positive prices and numeric values
- UNIQUE constraints to prevent duplicate enrollments and certificates
- NOT NULL constraints on required fields

### Comprehensive Indexing

Foreign keys and frequently queried columns are indexed for optimal query performance.

### Documentation

All tables and columns include descriptive comments that document their purpose and usage.

## Installation and Usage

### Prerequisites

- PostgreSQL 12 or higher
- psql command-line tool or a PostgreSQL client (like pgAdmin)

### Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/sazanik/sql-for-developers-project-136.git
   cd sql-for-developers-project-136
   ```

2. Connect to your PostgreSQL instance:
   ```bash
   psql -U your_username -d your_database
   ```

3. Execute the SQL script:
   ```sql
   \i database.sql
   ```