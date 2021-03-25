
/** Migrate usernames **/
WITH usernames AS (
	SELECT username
	FROM bad_posts
	UNION
	SELECT username
	FROM bad_comments
	UNION
	SELECT regexp_split_to_table(upvotes, ',')
	FROM bad_posts
	UNION
	SELECT regexp_split_to_table(downvotes, ',')
	FROM bad_posts
)
INSERT INTO users(username)
	SELECT DISTINCT username FROM usernames;

/** Migrate topics **/
INSERT INTO topics(name)
	SELECT DISTINCT topic FROM bad_posts;

/** Migrate posts **/
INSERT INTO posts(user_id, topic_id, title, url, content)
	SELECT u.id, t.id, SUBSTR(bp.title, 1, 100), bp.url, 				bp.text_content
  	FROM bad_posts AS bp
  	JOIN topics AS t
  	ON t.name = bp.topic
  	JOIN users AS u
	ON u.username = bp.username;

/** Migrate comments **/
INSERT INTO comments(post_id, user_id, content)
	SELECT u.id, bc.post_id, bc.text_content
	FROM bad_comments AS bc
	JOIN users AS u
	ON bc.username = u.username;

/** Migrate upvotes **/
WITH likes AS (
	SELECT id AS post_id,
		REGEXP_SPLIT_TO_TABLE(upvotes, ',') AS username
	FROM bad_posts
)
INSERT INTO votes(post_id, user_id, vote)
	SELECT l.post_id, u.id, 1
	FROM likes AS l
	JOIN users AS u
	ON u.username = l.username;

/** Migrate downvotes **/
WITH dislikes AS (
	SELECT id AS post_id,
		REGEXP_SPLIT_TO_TABLE(downvotes, ',') AS username
	FROM bad_posts
)
INSERT INTO votes(post_id, user_id, vote)
	SELECT l.post_id, u.id, -1
	FROM dislikes AS l
	JOIN users AS u
	ON u.username = l.username;
