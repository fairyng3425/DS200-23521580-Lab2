/* * BÀI 2: Thống kê dữ liệu */

-- =======================================================================
-- PHẦN 1: TIỀN XỬ LÝ (Kế thừa từ Bài 1 để có dữ liệu sạch)
-- =======================================================================

data_raw = LOAD 'file:///C:/Lab2/hotel-review.csv' USING PigStorage(';') AS (
    id:chararray, 
    review:chararray, 
    topic:chararray, 
    aspect:chararray, 
    sentiment:chararray
);

data_norm = FOREACH data_raw GENERATE 
    id, topic, aspect, sentiment,
    REPLACE(LOWER(review), '[^a-zA-ZÀ-ỹà-ỹ\\s]', ' ') AS review_lc;

words = FOREACH data_norm GENERATE 
    id, topic, aspect, sentiment,
    FLATTEN(TOKENIZE(review_lc)) AS word;

words = FILTER words BY word IS NOT NULL AND TRIM(word) != '';

stopwords_raw = LOAD 'file:///C:/Lab2/stopwords.txt' USING TextLoader() AS (line:chararray);
stopwords = FOREACH stopwords_raw GENERATE TRIM(LOWER(line)) AS stop;

joined = JOIN words BY word LEFT OUTER, stopwords BY stop;
words_clean = FILTER joined BY stopwords::stop IS NULL;

-- Dữ liệu sạch đã sẵn sàng
result_clean = FOREACH words_clean GENERATE 
    words::id AS id, words::word AS word, words::topic AS topic, words::aspect AS aspect, words::sentiment AS sentiment;


-- =======================================================================
-- PHẦN 2: THỰC HIỆN YÊU CẦU BÀI 2
-- =======================================================================

-- Yêu cầu 1: Thống kê tần số xuất hiện của các từ (Chỉ lấy > 500 lần)
word_groups = GROUP result_clean BY word;
word_freq = FOREACH word_groups GENERATE 
    group AS word, 
    COUNT(result_clean) AS freq;

freq_gt500 = FILTER word_freq BY freq > 500;
freq_sorted = ORDER freq_gt500 BY freq DESC; -- Sắp xếp giảm dần cho đẹp

STORE freq_sorted INTO 'file:///C:/Lab2/output_bai2_word_freq' USING PigStorage('\t');


-- Yêu cầu 2: Thống kê số bình luận theo phân loại (topic/category)
-- Lưu ý: Phải đếm trên data_raw ban đầu để biết chính xác số lượng bình luận
topic_groups = GROUP data_raw BY topic;
topic_counts = FOREACH topic_groups GENERATE 
    group AS topic, 
    COUNT(data_raw) AS num_comments;

topic_sorted = ORDER topic_counts BY num_comments DESC;

STORE topic_sorted INTO 'file:///C:/Lab2/output_bai2_topic' USING PigStorage('\t');


-- Yêu cầu 3: Thống kê số bình luận theo khía cạnh đánh giá (aspect)
aspect_groups = GROUP data_raw BY aspect;
aspect_counts = FOREACH aspect_groups GENERATE 
    group AS aspect, 
    COUNT(data_raw) AS num_comments;

aspect_sorted = ORDER aspect_counts BY num_comments DESC;

STORE aspect_sorted INTO 'file:///C:/Lab2/output_bai2_aspect' USING PigStorage('\t');