CREATE TABLE post (
	id SERIAL PRIMARY KEY,
	tags text[],
	title text,
	body text,
	posted timestamp DEFAULT current_timestamp
);
