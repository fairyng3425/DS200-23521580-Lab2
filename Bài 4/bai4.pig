/* * BÀI 4: Tìm Top 5 từ Tích cực/Tiêu cực nhất theo từng Phân loại (topic) */

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

-- Trích xuất các cột cần thiết cho Bài 4
data_clean = FOREACH words_clean GENERATE 
    words::topic AS topic,
    words::word AS word,
    words::sentiment AS sentiment;


-- =======================================================================
-- PHẦN 2: TÌM 5 TỪ TÍCH CỰC NHẤT THEO TỪNG TOPIC
-- =======================================================================
pos_data = FILTER data_clean BY sentiment == 'positive';

-- Đếm tần số xuất hiện của mỗi từ trong từng topic
pos_word_group = GROUP pos_data BY (topic, word);
pos_word_count = FOREACH pos_word_group GENERATE 
    group.topic AS topic, 
    group.word AS word, 
    COUNT(pos_data) AS freq;

-- Gom lại theo Topic và tìm Top 5 từ xuất hiện nhiều nhất
pos_topic_group = GROUP pos_word_count BY topic;
pos_top5 = FOREACH pos_topic_group {
    sorted = ORDER pos_word_count BY freq DESC;
    top = LIMIT sorted 5;
    -- Dùng FLATTEN kết hợp chọn đúng 2 cột (word, freq) để không bị lặp cột topic
    GENERATE group AS topic, FLATTEN(top.(word, freq));
};

STORE pos_top5 INTO 'file:///C:/Lab2/output_bai4_positive' USING PigStorage('\t');


-- =======================================================================
-- PHẦN 3: TÌM 5 TỪ TIÊU CỰC NHẤT THEO TỪNG TOPIC
-- =======================================================================
neg_data = FILTER data_clean BY sentiment == 'negative';

-- Đếm tần số xuất hiện của mỗi từ trong từng topic
neg_word_group = GROUP neg_data BY (topic, word);
neg_word_count = FOREACH neg_word_group GENERATE 
    group.topic AS topic, 
    group.word AS word, 
    COUNT(neg_data) AS freq;

-- Gom lại theo Topic và tìm Top 5 từ xuất hiện nhiều nhất
neg_topic_group = GROUP neg_word_count BY topic;
neg_top5 = FOREACH neg_topic_group {
    sorted = ORDER neg_word_count BY freq DESC;
    top = LIMIT sorted 5;
    GENERATE group AS topic, FLATTEN(top.(word, freq));
};

STORE neg_top5 INTO 'file:///C:/Lab2/output_bai4_negative' USING PigStorage('\t');