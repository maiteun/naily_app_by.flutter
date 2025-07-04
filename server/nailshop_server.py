from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)
DB_FILE = 'nailshop.db'

# DB 초기화
def init_db():
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute('''
            CREATE TABLE IF NOT EXISTS shops (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                lat REAL,
                lng REAL
            )
        ''')
        c.execute('''
            CREATE TABLE IF NOT EXISTS available_times (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                shop_id INTEGER,
                time TEXT,
                service TEXT,
                FOREIGN KEY(shop_id) REFERENCES shops(id)
            )
        ''')
        c.execute('''
            CREATE TABLE IF NOT EXISTS reservations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user TEXT,
                place TEXT,
                time TEXT,
                service TEXT
            )
        ''')

        # 샘플 데이터가 없으면 삽입
        c.execute('SELECT COUNT(*) FROM shops')
        if c.fetchone()[0] == 0:
            c.execute("INSERT INTO shops (name, lat, lng) VALUES (?, ?, ?)", ('네일샵 라뷰', 37.307670, 127.126336))
            c.execute("INSERT INTO shops (name, lat, lng) VALUES (?, ?, ?)", ('네일샵 블룸', 37.308000, 127.127000))
            c.execute("INSERT INTO shops (name, lat, lng) VALUES (?, ?, ?)", ('네일샵 데이지', 37.307200, 127.125800))

            for shop_id in range(1, 4):
                for t, s in [
                    ('13:00', 'Only Clinic'),
                    ('14:00', 'Art Design'),
                    ('15:00', 'Gel Polish'),
                    ('16:00', 'Care & Polish'),
                    ('17:00', 'Special Spa')
                ]:
                    c.execute("INSERT INTO available_times (shop_id, time, service) VALUES (?, ?, ?)", (shop_id, t, s))

        conn.commit()
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    user_id = data.get('id')
    password = data.get('password')

    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute('SELECT role FROM users WHERE username=? AND password=?', (user_id, password))

        result = c.fetchone()

    if result:
        return jsonify({'status': 'success', 'role': result[0]})
    else:
        return jsonify({'status': 'fail', 'message': 'Invalid credentials'}), 401

@app.route('/shops', methods=['GET'])
def get_shops():
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("SELECT id, name, lat, lng FROM shops")
        shops = []
        for shop_id, name, lat, lng in c.fetchall():
            c.execute("SELECT time, service FROM available_times WHERE shop_id=?", (shop_id,))
            times = [{'time': row[0], 'service': row[1]} for row in c.fetchall()]
            shops.append({
                'name': name,
                'location': {'lat': lat, 'lng': lng},
                'availableTimes': times
            })
    return jsonify(shops)

@app.route('/reservations', methods=['POST'])
def create_reservation():
    data = request.json
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute('''
            INSERT INTO reservations (user, place, time, service)
            VALUES (?, ?, ?, ?)
        ''', (data['user'], data['place'], data['time'], data['service']))
        conn.commit()
    return jsonify({'status': 'ok'})

@app.route('/reservations', methods=['GET'])
def get_reservations():
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("SELECT user, place, time, service FROM reservations")
        rows = [{'user': r[0], 'place': r[1], 'time': r[2], 'service': r[3]} for r in c.fetchall()]
    return jsonify(rows)

if __name__ == '__main__':
    init_db()
    app.run(port=8080, debug=True)
