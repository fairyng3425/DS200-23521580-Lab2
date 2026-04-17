/* * BÀI 3: Tìm khía cạnh Tiêu cực nhất và Tích cực nhất */

-- 1. Load dữ liệu nguyên bản
data_raw = LOAD 'file:///C:/Lab2/hotel-review.csv' USING PigStorage(';') AS (
    id:chararray, 
    review:chararray, 
    topic:chararray, 
    aspect:chararray, 
    sentiment:chararray
);

-- =======================================================================
-- TÌM KHÍA CẠNH TIÊU CỰC (NEGATIVE) NHẤT
-- =======================================================================

-- Lọc lấy các bình luận tiêu cực
neg_data = FILTER data_raw BY sentiment == 'negative';

-- Gom nhóm theo aspect và đếm số lượng
neg_group = GROUP neg_data BY aspect;
neg_count = FOREACH neg_group GENERATE 
    group AS aspect, 
    COUNT(neg_data) AS total_neg;

-- Sắp xếp giảm dần và chỉ lấy vị trí TOP 1
neg_sorted = ORDER neg_count BY total_neg DESC;
neg_top1 = LIMIT neg_sorted 1;

-- Lưu kết quả
STORE neg_top1 INTO 'file:///C:/Lab2/output_bai3_negative' USING PigStorage('\t');


-- =======================================================================
-- TÌM KHÍA CẠNH TÍCH CỰC (POSITIVE) NHẤT
-- =======================================================================

-- Lọc lấy các bình luận tích cực
pos_data = FILTER data_raw BY sentiment == 'positive';

-- Gom nhóm theo aspect và đếm số lượng
pos_group = GROUP pos_data BY aspect;
pos_count = FOREACH pos_group GENERATE 
    group AS aspect, 
    COUNT(pos_data) AS total_pos;

-- Sắp xếp giảm dần và chỉ lấy vị trí TOP 1
pos_sorted = ORDER pos_count BY total_pos DESC;
pos_top1 = LIMIT pos_sorted 1;

-- Lưu kết quả
STORE pos_top1 INTO 'file:///C:/Lab2/output_bai3_positive' USING PigStorage('\t');