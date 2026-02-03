package dto;

import java.time.LocalDateTime;

public class GameDTO {

	private String game_id;
	private String user_id;
	private String game_type;
	private String game_level;
	private String play_time;
	private int score;
	private LocalDateTime playedAt;

	public String getGame_id() {
		return game_id;
	}

	public void setGame_id(String game_id) {
		this.game_id = game_id;
	}

	public String getUser_id() {
		return user_id;
	}

	public void setUser_id(String user_id) {
		this.user_id = user_id;
	}

	public String getGame_type() {
		return game_type;
	}

	public void setGame_type(String game_type) {
		this.game_type = game_type;
	}

	public String getGame_level() {
		return game_level;
	}

	public void setGame_level(String game_level) {
		this.game_level = game_level;
	}

	public String getPlay_time() {
		return play_time;
	}

	public void setPlay_time(String play_time) {
		this.play_time = play_time;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

	public LocalDateTime getPlayedAt() {
		return playedAt;
	}

	public void setPlayedAt(LocalDateTime playedAt) {
		this.playedAt = playedAt;
	}

}