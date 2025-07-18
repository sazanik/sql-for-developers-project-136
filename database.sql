-- Creating lessons table
CREATE TABLE lessons
(
    id                 SERIAL PRIMARY KEY,
    title              VARCHAR(255) NOT NULL,
    content            TEXT,
    video_url          VARCHAR(255),
    position_in_course INTEGER      NOT NULL,
    created_at         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    course_id          INTEGER      NOT NULL,
    is_deleted         BOOLEAN                  DEFAULT FALSE,
    FOREIGN KEY (course_id) REFERENCES courses (id)
);

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

-- Creating programs table
CREATE TABLE programs
(
    id           SERIAL PRIMARY KEY,
    title        VARCHAR(255)   NOT NULL,
    price        DECIMAL(10, 2) NOT NULL,
    program_type VARCHAR(50)    NOT NULL,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Creating courses_modules junction table for many-to-many relationship
CREATE TABLE courses_modules
(
    course_id INTEGER NOT NULL,
    module_id INTEGER NOT NULL,
    PRIMARY KEY (course_id, module_id),
    FOREIGN KEY (course_id) REFERENCES courses (id),
    FOREIGN KEY (module_id) REFERENCES modules (id)
);

-- Creating modules_programs junction table for many-to-many relationship
CREATE TABLE modules_programs
(
    module_id  INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    PRIMARY KEY (module_id, program_id),
    FOREIGN KEY (module_id) REFERENCES modules (id),
    FOREIGN KEY (program_id) REFERENCES programs (id)
);

-- Creating teaching_groups table
CREATE TABLE teaching_groups
(
    id         SERIAL PRIMARY KEY,
    slug       VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Creating users table
CREATE TABLE users
(
    id                SERIAL PRIMARY KEY,
    username          VARCHAR(255) NOT NULL,
    email             VARCHAR(255) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    role              VARCHAR(20)  NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    teaching_group_id INTEGER,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teaching_group_id) REFERENCES teaching_groups (id)
);

-- Creating enrollments table
CREATE TABLE enrollments
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER     NOT NULL,
    program_id INTEGER     NOT NULL,
    status     VARCHAR(20) NOT NULL CHECK (status IN
                                           ('active', 'pending', 'cancelled',
                                            'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (program_id) REFERENCES programs (id),
    UNIQUE (user_id, program_id)
);

-- Creating payments table
CREATE TABLE payments
(
    id            SERIAL PRIMARY KEY,
    enrollment_id INTEGER        NOT NULL,
    amount        DECIMAL(10, 2) NOT NULL,
    status        VARCHAR(20)    NOT NULL CHECK (status IN
                                                 ('pending', 'paid', 'failed',
                                                  'refunded')),
    payment_date  TIMESTAMP WITH TIME ZONE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments (id)
);

-- Creating program_completions table
CREATE TABLE program_completions
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER     NOT NULL,
    program_id INTEGER     NOT NULL,
    status     VARCHAR(20) NOT NULL CHECK (status IN
                                           ('active', 'completed', 'pending',
                                            'cancelled')),
    start_date TIMESTAMP WITH TIME ZONE,
    end_date   TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (program_id) REFERENCES programs (id),
    UNIQUE (user_id, program_id)
);

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
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (program_id) REFERENCES programs (id),
    UNIQUE (user_id, program_id)
);

-- Creating quizzes table
CREATE TABLE quizzes
(
    id         SERIAL PRIMARY KEY,
    lesson_id  INTEGER      NOT NULL,
    title      VARCHAR(255) NOT NULL,
    content    JSONB        NOT NULL, -- Using JSONB for storing tree-like question structure
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id)
);

-- Creating exercises table
CREATE TABLE exercises
(
    id           SERIAL PRIMARY KEY,
    lesson_id    INTEGER      NOT NULL,
    title        VARCHAR(255) NOT NULL,
    exercise_url VARCHAR(255) NOT NULL,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id)
);

-- Creating discussions table
CREATE TABLE discussions
(
    id         SERIAL PRIMARY KEY,
    lesson_id  INTEGER NOT NULL,
    content    JSONB   NOT NULL, -- Using JSONB for storing tree-like discussion structure
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id)
);

-- Creating blog table
CREATE TABLE blog
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER      NOT NULL,
    title      VARCHAR(255) NOT NULL,
    content    TEXT         NOT NULL,
    status     VARCHAR(20)  NOT NULL CHECK (status IN
                                            ('created', 'in_moderation',
                                             'published', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);