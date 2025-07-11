# naily ⭐🍄

Naily is a full-stack web platform for nail enthusiasts and designers.


Users can discover nearby nail shops available for immediate reservation, browse trendy nail designs like Instagram or Pinterest, and save their favorite designs by liking them.

Designers can freely upload their works with copyright protection to prevent imitation, and receive weekly reports on their designs to improve and keep up with trends.

## Technology Stack
✔️Flutter | web client <br>
✔️FLASK | backend<br>
✔️Supabase | cloud database, storage<br>
✔️SQlite3 | database<br>

## Getting Started

#### Requirements
- Flutter SDK (>=3.0.0 <4.0.0)
- sqlite3: 2.0.0
- Supabase account

#### [Clone the Repository]

 ``` git clone https://github.com/maiteun/naily_app_by.flutter.git cd naily_app_by.flutter ``` 

#### [Run the Backend Server]
Navigate to the server directory and start the Flask server:
<pre> cd server
pip install -r requirements.txt
python app.py </pre>

The server will start at http://127.0.0.1:8080.

####  [Run the Flutter Web Client]

Navigate to the client directory and run the Flutter web app:

<pre> cd client
flutter pub get
flutter run -d window </pre>


#### [Supabase Setup (Optional, for cloud features)]
Create a project on Supabase and obtain your Anon Key and API URL.

Add these values to your code or an .env file.

Create necessary tables and storage buckets in Supabase for photos and data.



### Architecture
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/72d13c28-b71e-44b6-8990-8793ddfeaf7f" />

### License
MIT license
