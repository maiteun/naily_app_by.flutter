-- shops 테이블 초기화
DELETE FROM shops;
DELETE FROM available_times;

-- 샵 3개 등록
INSERT INTO shops (name, lat, lng) VALUES 
('블링네일', 37.307670, 127.126336),
('큐트네일', 37.307870, 127.126536),
('럭셔리네일', 37.307470, 127.126136);

-- 예약 가능 시간대 등록
INSERT INTO available_times (shop_id, time, service) VALUES 
(1, '13:00', 'Only Clinic'),
(1, '14:00', 'Art Design'),
(1, '15:00', 'Gel Polish'),
(1, '16:00', 'FREE !'),
(1, '17:00', 'FREE !'),

(2, '12:30', 'FREE !'),
(2, '13:30', 'Gel Polish'),
(2, '14:30', 'FREE !'),
(2, '15:30', 'FREE !'),
(2, '16:30', 'FREE !'),

(3, '11:00', 'FREE !'),
(3, '12:00', 'Simple Care'),
(3, '13:00', 'Gel Polish'),
(3, '14:00', 'Art Design'),
(3, '15:00', 'FREE !');
