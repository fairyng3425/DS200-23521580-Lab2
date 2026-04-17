/* * BÀI 5: Tìm 5 từ liên quan nhất (xuất hiện nhiều nhất) theo từng Topic */

-- =======================================================================
-- PHẦN 1: TIỀN XỬ LÝ (Lọc sạch dữ liệu và stopword)
-- =======================================================================
data_raw = LOAD 'file:///C:/Lab2/hotel-review.csv' USING PigStorage(';') AS (
    id:chararray, 
    review:chararray, 
    topic:chararray, 
    aspect:chararray, 
    sentiment:chararray
);

data_norm = FOREACH data_raw GENERATE 
    topic,
    REPLACE(LOWER(review), '[^a-zA-ZÀ-ỹà-ỹ\\s]', ' ') AS review_lc;

words = FOREACH data_norm GENERATE 
    topic,
    FLATTEN(TOKENIZE(review_lc)) AS word;

words = FILTER words BY word IS NOT NULL AND TRIM(word) != '';

stopwords_raw = LOAD 'file:///C:/Lab2/stopwords.txt' USING TextLoader() AS (line:chararray);
stopwords = FOREACH stopwords_raw GENERATE TRIM(LOWER(line)) AS stop;

joined = JOIN words BY word LEFT OUTER, stopwords BY stop;
words_clean = FILTER joined BY stopwords::stop IS NULL;


-- =======================================================================
-- PHẦN 2: THỐNG KÊ TOP 5 TỪ THEO TOPIC
-- =======================================================================

-- 1. Đếm số lần xuất hiện của mỗi từ trong từng Topic (không phân biệt sentiment)
word_topic_group = GROUP words_clean BY (topic, word);
word_topic_count = FOREACH word_topic_group GENERATE 
    group.topic AS topic, 
    group.word AS word, 
    COUNT(words_clean) AS freq;

-- 2. Gom nhóm lại theo Topic để tìm Top 5
topic_group = GROUP word_topic_count BY topic;
top5_related = FOREACH topic_group {
    sorted = ORDER word_topic_count BY freq DESC;
    top = LIMIT sorted 5;
    -- Flatten kết quả để lấy đúng 2 cột: word và freq
    GENERATE group AS topic, FLATTEN(top.(word, freq));
};

-- 3. Lưu kết quả ra file
STORE top5_related INTO 'file:///C:/Lab2/output_bai5' USING PigStorage('\t');