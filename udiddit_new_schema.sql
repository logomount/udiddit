
/* New schema:
  a.	Allow new users to register:
      i.	Each username has to be unique
      ii.	Usernames can be composed of at most 25 characters
      iii.	Usernames can’t be empty
      iv.	We won’t worry about user passwords for this project */
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
	username VARCHAR(25) NOT NULL CHECK (LENGTH(TRIM(username)) > 0),
	last_logon TIMESTAMP DEFAULT NULL,
	CONSTRAINT unique_usernames UNIQUE (username)
);
CREATE INDEX ON users(last_logon);

/* b.	Allow registered users to create new topics:
      i.	Topic names have to be unique.
      ii.	The topic’s name is at most 30 characters
      iii.	The topic’s name can’t be empty
      iv.	Topics can have an optional description of at most 500 characters. */
CREATE TABLE topics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(30) NOT NULL CHECK (LENGTH(TRIM(name)) > 0),
	description VARCHAR(500) DEFAULT NULL,
	CONSTRAINT unique_names UNIQUE (name)
);

/* c.	Allow registered users to create new posts on existing topics:
      i.	Posts have a required title of at most 100 characters
      ii.	The title of a post can’t be empty.
      iii.	Posts should contain either a URL or a text content, but not both.
      iv.	If a topic gets deleted, all the posts associated with it should be automatically deleted too.
      v.	If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user. */
CREATE TABLE posts (
	id SERIAL PRIMARY KEY,
	user_id INTEGER REFERENCES users ON DELETE SET NULL,
  topic_id INTEGER NOT NULL REFERENCES topics ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL CHECK (LENGTH(TRIM(title)) > 0),
	url VARCHAR(4000) DEFAULT NULL,
	content TEXT DEFAULT NULL,
	created_on TIMESTAMP DEFAULT NULL,
	CONSTRAINT only_url_or_content
		CHECK ((url IS NOT NULL AND content IS NULL)
			OR (content IS NOT NULL AND url IS NULL)
	)
);
CREATE INDEX ON posts(created_on);
CREATE INDEX ON posts(url);

/* d.	Allow registered users to comment on existing posts:
      i.	A comment’s text content can’t be empty.
      ii.	Contrary to the current linear comments, the new structure should allow comment threads at arbitrary levels.
      iii.	If a post gets deleted, all comments associated with it should be automatically deleted too.
      iv.	If the user who created the comment gets deleted, then the comment will remain, but it will become dissociated from that user.
      v.	If a comment gets deleted, then all its descendants in the thread structure should be automatically deleted too. */
CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	top_level_comment_id INTEGER DEFAULT NULL,
  post_id INTEGER NOT NULL REFERENCES posts ON DELETE CASCADE,
  user_id INTEGER REFERENCES users ON DELETE SET NULL,
	content TEXT NOT NULL CHECK (LENGTH(TRIM(content)) > 0),
	created_on TIMESTAMP DEFAULT NULL,
	CONSTRAINT top_level_comment
		FOREIGN KEY (top_level_comment_id)
		REFERENCES comments (id)
		ON DELETE CASCADE
);
CREATE INDEX ON comments(created_on);
CREATE INDEX ON comments(top_level_comment_id);
				     
/* e.	Make sure that a given user can only vote once on a given post:
      i.	Hint: you can store the (up/down) value of the vote as the values 1 and -1 respectively.
      ii.	If the user who cast a vote gets deleted, then all their votes will remain, but will become dissociated from the user.
      iii.	If a post gets deleted, then all the votes for that post should be automatically deleted too. */
CREATE TABLE votes (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL REFERENCES posts ON DELETE CASCADE,
  user_id INTEGER REFERENCES users ON DELETE SET NULL,
  vote SMALLINT CHECK(vote = 1 OR vote = -1),
	CONSTRAINT one_vote_per_user UNIQUE(post_id, user_id)
);
CREATE INDEX ON votes(post_id);
