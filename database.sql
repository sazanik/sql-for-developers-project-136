-- Creating a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Creating ENUM types for various status and role fields
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
COMMENT ON TYPE user_role IS 'Defines possible user roles in the system';

CREATE TYPE enrollment_status AS ENUM ('active', 'pending', 'cancelled', 'completed');
COMMENT ON TYPE enrollment_status IS 'Defines possible statuses for program enrollments';

CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
COMMENT ON TYPE payment_status IS 'Defines possible statuses for payments';

CREATE TYPE program_completion_status AS ENUM ('active', 'completed', 'pending', 'cancelled');
COMMENT ON TYPE program_completion_status IS 'Defines possible statuses for program completions';

CREATE TYPE blog_status AS ENUM ('created', 'in_moderation', 'published', 'archived');
COMMENT ON TYPE blog_status IS 'Defines possible statuses for blog posts';

CREATE TYPE program_type AS ENUM ('certificate', 'degree', 'short_course');
COMMENT ON TYPE program_type IS 'Defines possible types of educational programs';

-- Creating courses table
CREATE TABLE courses
(
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted  BOOLEAN                  DEFAULT FALSE
);
COMMENT ON TABLE courses IS 'Stores information about individual courses';
COMMENT ON COLUMN courses.title IS 'The title of the course';
COMMENT ON COLUMN courses.description IS 'Detailed description of the course content';
COMMENT ON COLUMN courses.is_deleted IS 'Soft delete flag to mark courses as deleted without removing them';

-- Creating trigger for courses updated_at
CREATE TRIGGER update_courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating modules table
CREATE TABLE modules
(
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted  BOOLEAN                  DEFAULT FALSE
);
COMMENT ON TABLE modules IS 'Stores information about modules that group related courses';
COMMENT ON COLUMN modules.title IS 'The title of the module';
COMMENT ON COLUMN modules.description IS 'Detailed description of the module content';
COMMENT ON COLUMN modules.is_deleted IS 'Soft delete flag to mark modules as deleted without removing them';

-- Creating trigger for modules updated_at
CREATE TRIGGER update_modules_updated_at
    BEFORE UPDATE ON modules
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating programs table
CREATE TABLE programs
(
    id           SERIAL PRIMARY KEY,
    title        VARCHAR(255)   NOT NULL,
    price        DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    program_type program_type   NOT NULL,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted   BOOLEAN                  DEFAULT FALSE
);
COMMENT ON TABLE programs IS 'Stores information about educational programs that students can enroll in';
COMMENT ON COLUMN programs.title IS 'The title of the program';
COMMENT ON COLUMN programs.price IS 'The price of the program in decimal format';
COMMENT ON COLUMN programs.program_type IS 'The type of program (certificate, degree, short_course)';
COMMENT ON COLUMN programs.is_deleted IS 'Soft delete flag to mark programs as deleted without removing them';

-- Creating trigger for programs updated_at
CREATE TRIGGER update_programs_updated_at
    BEFORE UPDATE ON programs
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating courses_modules junction table for many-to-many relationship
CREATE TABLE courses_modules
(
    course_id INTEGER NOT NULL,
    module_id INTEGER NOT NULL,
    PRIMARY KEY (course_id, module_id),
    FOREIGN KEY (course_id) REFERENCES courses (id),
    FOREIGN KEY (module_id) REFERENCES modules (id)
);
COMMENT ON TABLE courses_modules IS 'Junction table for the many-to-many relationship between courses and modules';
COMMENT ON COLUMN courses_modules.course_id IS 'Foreign key reference to the courses table';
COMMENT ON COLUMN courses_modules.module_id IS 'Foreign key reference to the modules table';

-- Creating indexes for courses_modules
CREATE INDEX idx_courses_modules_course_id ON courses_modules(course_id);
CREATE INDEX idx_courses_modules_module_id ON courses_modules(module_id);

-- Creating modules_programs junction table for many-to-many relationship
CREATE TABLE modules_programs
(
    module_id  INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    PRIMARY KEY (module_id, program_id),
    FOREIGN KEY (module_id) REFERENCES modules (id),
    FOREIGN KEY (program_id) REFERENCES programs (id)
);
COMMENT ON TABLE modules_programs IS 'Junction table for the many-to-many relationship between modules and programs';
COMMENT ON COLUMN modules_programs.module_id IS 'Foreign key reference to the modules table';
COMMENT ON COLUMN modules_programs.program_id IS 'Foreign key reference to the programs table';

-- Creating indexes for modules_programs
CREATE INDEX idx_modules_programs_module_id ON modules_programs(module_id);
CREATE INDEX idx_modules_programs_program_id ON modules_programs(program_id);

-- Creating lessons table
CREATE TABLE lessons
(
    id                 SERIAL PRIMARY KEY,
    title              VARCHAR(255) NOT NULL,
    content            TEXT,
    video_url          VARCHAR(255),
    position_in_course INTEGER      NOT NULL CHECK (position_in_course > 0),
    course_id          INTEGER      NOT NULL,
    created_at         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted         BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (course_id) REFERENCES courses (id)
);
COMMENT ON TABLE lessons IS 'Stores individual learning units that make up courses';
COMMENT ON COLUMN lessons.title IS 'The title of the lesson';
COMMENT ON COLUMN lessons.content IS 'The textual content of the lesson';
COMMENT ON COLUMN lessons.video_url IS 'URL to the video content for the lesson';
COMMENT ON COLUMN lessons.position_in_course IS 'The order of the lesson within its course';
COMMENT ON COLUMN lessons.course_id IS 'Foreign key reference to the courses table';
COMMENT ON COLUMN lessons.is_deleted IS 'Soft delete flag to mark lessons as deleted without removing them';

-- Creating trigger for lessons updated_at
CREATE TRIGGER update_lessons_updated_at
    BEFORE UPDATE ON lessons
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating index for lessons
CREATE INDEX idx_lessons_course_id ON lessons(course_id);

-- Creating teaching_groups table
CREATE TABLE teaching_groups
(
    id         SERIAL PRIMARY KEY,
    slug       VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN                  DEFAULT FALSE
);
COMMENT ON TABLE teaching_groups IS 'Stores information about teaching groups that teachers can be assigned to';
COMMENT ON COLUMN teaching_groups.slug IS 'A unique identifier for the teaching group used in URLs';
COMMENT ON COLUMN teaching_groups.is_deleted IS 'Soft delete flag to mark teaching groups as deleted without removing them';

-- Creating trigger for teaching_groups updated_at
CREATE TRIGGER update_teaching_groups_updated_at
    BEFORE UPDATE ON teaching_groups
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating users table
CREATE TABLE users
(
    id                SERIAL PRIMARY KEY,
    username          VARCHAR(255) NOT NULL,
    email             VARCHAR(255) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    role              user_role    NOT NULL,
    teaching_group_id INTEGER,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted        BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (teaching_group_id) REFERENCES teaching_groups (id)
);
COMMENT ON TABLE users IS 'Stores all user accounts including students, teachers, and administrators';
COMMENT ON COLUMN users.username IS 'The username for the user account';
COMMENT ON COLUMN users.email IS 'The email address for the user account, must be unique';
COMMENT ON COLUMN users.password_hash IS 'The hashed password for the user account';
COMMENT ON COLUMN users.role IS 'User role determining permissions: student, teacher, or admin';
COMMENT ON COLUMN users.teaching_group_id IS 'Foreign key reference to the teaching_groups table for teachers';
COMMENT ON COLUMN users.is_deleted IS 'Soft delete flag to mark users as deleted without removing them';

-- Creating trigger for users updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating index for users
CREATE INDEX idx_users_teaching_group_id ON users(teaching_group_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Creating enrollments table
CREATE TABLE enrollments
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER           NOT NULL,
    program_id INTEGER           NOT NULL,
    status     enrollment_status NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (program_id) REFERENCES programs (id),
    UNIQUE (user_id, program_id)
);
COMMENT ON TABLE enrollments IS 'Tracks user enrollment in educational programs';
COMMENT ON COLUMN enrollments.user_id IS 'Foreign key reference to the users table';
COMMENT ON COLUMN enrollments.program_id IS 'Foreign key reference to the programs table';
COMMENT ON COLUMN enrollments.status IS 'Current status of the enrollment: active, pending, cancelled, or completed';
COMMENT ON COLUMN enrollments.is_deleted IS 'Soft delete flag to mark enrollments as deleted without removing them';

-- Creating trigger for enrollments updated_at
CREATE TRIGGER update_enrollments_updated_at
    BEFORE UPDATE ON enrollments
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating indexes for enrollments
CREATE INDEX idx_enrollments_user_id ON enrollments(user_id);
CREATE INDEX idx_enrollments_program_id ON enrollments(program_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);

-- Creating payments table
CREATE TABLE payments
(
    id            SERIAL PRIMARY KEY,
    enrollment_id INTEGER        NOT NULL,
    amount        DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    status        payment_status NOT NULL,
    payment_date  TIMESTAMP WITH TIME ZONE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted    BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments (id)
);
COMMENT ON TABLE payments IS 'Tracks payment information for program enrollments';
COMMENT ON COLUMN payments.enrollment_id IS 'Foreign key reference to the enrollments table';
COMMENT ON COLUMN payments.amount IS 'The payment amount in decimal format';
COMMENT ON COLUMN payments.status IS 'Current status of the payment: pending, paid, failed, or refunded';
COMMENT ON COLUMN payments.payment_date IS 'The date and time when the payment was processed';
COMMENT ON COLUMN payments.is_deleted IS 'Soft delete flag to mark payments as deleted without removing them';

-- Creating trigger for payments updated_at
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating indexes for payments
CREATE INDEX idx_payments_enrollment_id ON payments(enrollment_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);

-- Creating program_completions table
CREATE TABLE program_completions
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER                  NOT NULL,
    program_id INTEGER                  NOT NULL,
    status     program_completion_status NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date   TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (program_id) REFERENCES programs (id),
    UNIQUE (user_id, program_id)
);
COMMENT ON TABLE program_completions IS 'Tracks user progress and completion of educational programs';
COMMENT ON COLUMN program_completions.user_id IS 'Foreign key reference to the users table';
COMMENT ON COLUMN program_completions.program_id IS 'Foreign key reference to the programs table';
COMMENT ON COLUMN program_completions.status IS 'Current status of the program completion: active, completed, pending, or cancelled';
COMMENT ON COLUMN program_completions.start_date IS 'The date and time when the user started the program';
COMMENT ON COLUMN program_completions.end_date IS 'The date and time when the user completed the program';
COMMENT ON COLUMN program_completions.is_deleted IS 'Soft delete flag to mark program completions as deleted without removing them';

-- Creating trigger for program_completions updated_at
CREATE TRIGGER update_program_completions_updated_at
    BEFORE UPDATE ON program_completions
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating indexes for program_completions
CREATE INDEX idx_program_completions_user_id ON program_completions(user_id);
CREATE INDEX idx_program_completions_program_id ON program_completions(program_id);
CREATE INDEX idx_program_completions_status ON program_completions(status);

-- Creating certificates table
CREATE TABLE certificates
(
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER                  NOT NULL,
    program_id      INTEGER                  NOT NULL,
    certificate_url VARCHAR(255)             NOT NULL,
    issued_at       TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted      BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (program_id) REFERENCES programs (id),
    UNIQUE (user_id, program_id)
);
COMMENT ON TABLE certificates IS 'Stores certificates issued to users upon program completion';
COMMENT ON COLUMN certificates.user_id IS 'Foreign key reference to the users table';
COMMENT ON COLUMN certificates.program_id IS 'Foreign key reference to the programs table';
COMMENT ON COLUMN certificates.certificate_url IS 'URL to access the certificate';
COMMENT ON COLUMN certificates.issued_at IS 'The date and time when the certificate was issued';
COMMENT ON COLUMN certificates.is_deleted IS 'Soft delete flag to mark certificates as deleted without removing them';

-- Creating trigger for certificates updated_at
CREATE TRIGGER update_certificates_updated_at
    BEFORE UPDATE ON certificates
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating indexes for certificates
CREATE INDEX idx_certificates_user_id ON certificates(user_id);
CREATE INDEX idx_certificates_program_id ON certificates(program_id);
CREATE INDEX idx_certificates_issued_at ON certificates(issued_at);

-- Creating quizzes table
CREATE TABLE quizzes
(
    id         SERIAL PRIMARY KEY,
    lesson_id  INTEGER      NOT NULL,
    title      VARCHAR(255) NOT NULL,
    content    JSONB        NOT NULL, -- Using JSONB for storing tree-like question structure
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id)
);
COMMENT ON TABLE quizzes IS 'Stores quizzes associated with lessons';
COMMENT ON COLUMN quizzes.lesson_id IS 'Foreign key reference to the lessons table';
COMMENT ON COLUMN quizzes.title IS 'The title of the quiz';
COMMENT ON COLUMN quizzes.content IS 'JSONB structure containing quiz questions and answers';
COMMENT ON COLUMN quizzes.is_deleted IS 'Soft delete flag to mark quizzes as deleted without removing them';

-- Creating trigger for quizzes updated_at
CREATE TRIGGER update_quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating index for quizzes
CREATE INDEX idx_quizzes_lesson_id ON quizzes(lesson_id);

-- Creating exercises table
CREATE TABLE exercises
(
    id           SERIAL PRIMARY KEY,
    lesson_id    INTEGER      NOT NULL,
    title        VARCHAR(255) NOT NULL,
    exercise_url VARCHAR(255) NOT NULL,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted   BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id)
);
COMMENT ON TABLE exercises IS 'Stores exercises associated with lessons';
COMMENT ON COLUMN exercises.lesson_id IS 'Foreign key reference to the lessons table';
COMMENT ON COLUMN exercises.title IS 'The title of the exercise';
COMMENT ON COLUMN exercises.exercise_url IS 'URL to access the exercise content';
COMMENT ON COLUMN exercises.is_deleted IS 'Soft delete flag to mark exercises as deleted without removing them';

-- Creating trigger for exercises updated_at
CREATE TRIGGER update_exercises_updated_at
    BEFORE UPDATE ON exercises
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating index for exercises
CREATE INDEX idx_exercises_lesson_id ON exercises(lesson_id);

-- Creating discussions table
CREATE TABLE discussions
(
    id         SERIAL PRIMARY KEY,
    lesson_id  INTEGER NOT NULL,
    content    JSONB   NOT NULL, -- Using JSONB for storing tree-like discussion structure
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id)
);
COMMENT ON TABLE discussions IS 'Stores threaded discussions associated with lessons';
COMMENT ON COLUMN discussions.lesson_id IS 'Foreign key reference to the lessons table';
COMMENT ON COLUMN discussions.content IS 'JSONB structure containing threaded discussion content';
COMMENT ON COLUMN discussions.is_deleted IS 'Soft delete flag to mark discussions as deleted without removing them';

-- Creating trigger for discussions updated_at
CREATE TRIGGER update_discussions_updated_at
    BEFORE UPDATE ON discussions
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating index for discussions
CREATE INDEX idx_discussions_lesson_id ON discussions(lesson_id);

-- Creating blog table
CREATE TABLE blog
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER      NOT NULL,
    title      VARCHAR(255) NOT NULL,
    content    TEXT         NOT NULL,
    status     blog_status  NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users (id)
);
COMMENT ON TABLE blog IS 'Stores blog posts created by users';
COMMENT ON COLUMN blog.user_id IS 'Foreign key reference to the users table';
COMMENT ON COLUMN blog.title IS 'The title of the blog post';
COMMENT ON COLUMN blog.content IS 'The content of the blog post';
COMMENT ON COLUMN blog.status IS 'Current status of the blog post: created, in_moderation, published, or archived';
COMMENT ON COLUMN blog.is_deleted IS 'Soft delete flag to mark blog posts as deleted without removing them';

-- Creating trigger for blog updated_at
CREATE TRIGGER update_blog_updated_at
    BEFORE UPDATE ON blog
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Creating indexes for blog
CREATE INDEX idx_blog_user_id ON blog(user_id);
CREATE INDEX idx_blog_status ON blog(status);