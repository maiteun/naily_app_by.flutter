-- 기존 데이터 초기화
DELETE FROM shops;
DELETE FROM available_times;

-- shops 테이블 초기화
INSERT INTO shops (id, name, lat, lng) VALUES
(1, 'Nail Studio', 37.2479789, 127.0776135),
(2, 'Nail shop1', 37.2510000, 127.0810000),
(3, 'Nail shop2', 37.2475000, 127.0725000);

-- 예약 가능 시간대 초기화
INSERT INTO available_times (shop_id, time, service) VALUES
-- Nail Studio
(1, '10:00', 'Basic Care'),
(1, '11:00', 'Gel Polish'),
(1, '12:00', 'Art Design'),
(1, '13:00', 'FREE'),
(1, '14:00', 'FREE'),

-- Nail shop1
(2, '10:30', 'Basic Care'),
(2, '11:30', 'Gel Polish'),
(2, '12:30', 'FREE'),
(2, '13:30', 'Art Design'),
(2, '14:30', 'FREE'),

-- Nail shop2
(3, '09:00', 'Simple Care'),
(3, '10:00', 'Gel Polish'),
(3, '11:00', 'FREE'),
(3, '12:00', 'Art Design'),
(3, '13:00', 'FREE');
