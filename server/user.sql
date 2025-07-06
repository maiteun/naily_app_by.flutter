--user랑 master구분을 위한 테이블

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL
);

INSERT OR IGNORE INTO users (username, password, role) VALUES ('user', '1234', 'user');
INSERT OR IGNORE INTO users (username, password, role) VALUES ('master', '1234', 'admin');
