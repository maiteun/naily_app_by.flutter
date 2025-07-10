from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)
DB_FILE = 'nailshop.db'

# DB 테이블만 초기화
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
                'id': shop_id,
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


@app.route('/reservations', methods=['DELETE'])
def cancel_reservation():
    data = request.json
    user = data.get('user')
    place = data.get('place')
    time = data.get('time')
    service = data.get('service')

    if not all([user, place, time, service]):
        return jsonify({'status': 'fail', 'message': 'Missing fields'}), 400

    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute('''
            DELETE FROM reservations
            WHERE user=? AND place=? AND time=? AND service=?
        ''', (user, place, time, service))
        conn.commit()

        if c.rowcount > 0:
            return jsonify({'status': 'ok', 'message': 'Reservation cancelled'})
        else:
            return jsonify({'status': 'fail', 'message': 'No reservation found'}), 404


@app.route('/available_times', methods=['POST'])
def add_available_time():
    data = request.json
    shop_id = data.get('shop_id')
    time = data.get('time')
    service = data.get('service')

    if not all([shop_id, time, service]):
        return jsonify({'status': 'fail', 'message': 'Missing required fields'}), 400

    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute('''
            INSERT INTO available_times (shop_id, time, service)
            VALUES (?, ?, ?)
        ''', (shop_id, time, service))
        conn.commit()

    return jsonify({'status': 'ok', 'message': 'Available time added'})

if __name__ == '__main__':
    init_db()  # 테이블만 만들고 데이터는 삽입하지 않음
    app.run(port=8080, debug=True)
