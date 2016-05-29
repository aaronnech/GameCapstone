CREATE TABLE all_data(
	time_stamp INTEGER NOT NULL,
	user_id TEXT NOT NULL,
	event_number INTEGER NOT NULL,
	host_name TEXT NOT NULL,
	screen_name TEXT NOT NULL,
	event_category TEXT NOT NULL,
	event_name TEXT NOT NULL,
	event_value INTEGER NOT NULL,
	screen_token TEXT NOT NULL,
	game_version TEXT NOT NULL,
	ab_value INTEGER NOT NULL,
	PRIMARY KEY(
		user_id,
		event_number,
		host_name,
		screen_name,
		event_category,
		event_name,
		event_value,
		screen_token,
		game_version,
		ab_value
	)
);
