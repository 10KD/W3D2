CREATE TABLE users(
id INTEGER PRIMARY KEY,
fname TEXT NOT NULL,
lname TEXT NOT NULL
);

CREATE TABLE  questions(
id INTEGER PRIMARY KEY,
title TEXT NOT NULL,
body TEXT NOT NULL,
users_id INTEGER NOT NULL,
FOREIGN KEY (users_id) REFERENCES users(id)
);

CREATE TABLE  question_follows(
id INTEGER PRIMARY KEY,
user_id INTEGER NOT NULL,
question_id INTEGER NOT NULL,

FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (question_id) REFERENCES questions(id)

);
CREATE TABLE  replies(
id INTEGER PRIMARY KEY,
question_id INTEGER NOT NULL,
user_id INTEGER NOT NULL,
parent_reply_id INTEGER,
body TEXT,

FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (question_id) REFERENCES questions(id),
FOREIGN KEY (parent_reply_id) REFERENCES question_follows(id)
);

CREATE TABLE question_likes(
id INTEGER PRIMARY KEY,
user_id INTEGER NOT NULL,
question_id INTEGER NOT NULL,

FOREIGN KEY(user_id) REFERENCES users(id),
FOREIGN KEY(question_id) REFERENCES questions(id)

);

INSERT INTO
  users(fname,lname)
VALUES
  ('Don','Kim'),
  ('Jack','Wu');

INSERT INTO
  questions(title,body,users_id)
VALUES
  ("Is App Academy hard?", "I heard App academy is really hard, is that true?", (SELECT id FROM users WHERE fname = 'Don') ),
  ("Is Hack Reactor hard?", "I heard HR is really hard, is that false?", (SELECT id FROM users WHERE fname = 'Jack') );

-- INSERT INTO
--     question_follows(user_id,question_id)
-- VALUES
--     (SELECT id FROM users WHERE fname = 'Don')
--     (SELECT id FROM users WHERE fname = 'Don')
