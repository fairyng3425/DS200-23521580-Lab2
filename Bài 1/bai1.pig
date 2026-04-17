/* * BÀI 1: Tiền xử lý dữ liệu (Phiên bản Tối ưu nhất) */

-- 1. Load dữ liệu (Đổi tên cột cho sát với dataset: review, topic)
data_raw = LOAD 'file:///C:/Lab2/hotel-review.csv' USING PigStorage(';') AS (
    id:chararray, 
    review:chararray, 
    topic:chararray, 
    aspect:chararray, 
    sentiment:chararray
);

-- 2. Đưa về chữ thường và loại bỏ dấu câu trong 1 BƯỚC DUY NHẤT
data_norm = FOREACH data_raw GENERATE 
    id, topic, aspect, sentiment,
    REPLACE(LOWER(review), '[^a-zA-ZÀ-ỹà-ỹ\\s]', ' ') AS review_lc;

-- 3. Tách từ (TOKENIZE), trải phẳng (FLATTEN) và lọc từ rỗng
words = FOREACH data_norm GENERATE 
    id, topic, aspect, sentiment,
    FLATTEN(TOKENIZE(review_lc)) AS word;

words = FILTER words BY word IS NOT NULL AND TRIM(word) != '';

-- 4. Load và chuẩn hóa stopwords
stopwords_raw = LOAD 'file:///C:/Lab2/stopwords.txt' USING TextLoader() AS (line:chararray);
stopwords = FOREACH stopwords_raw GENERATE TRIM(LOWER(line)) AS stop;

-- 5. Loại bỏ stopwords bằng LEFT OUTER JOIN
joined = JOIN words BY word LEFT OUTER, stopwords BY stop;
words_clean = FILTER joined BY stopwords::stop IS NULL;

-- 6. Định dạng lại bảng kết quả cuối cùng
result_bai1 = FOREACH words_clean GENERATE 
    words::id AS id,
    words::word AS word,
    words::topic AS topic,
    words::aspect AS aspect,
    words::sentiment AS sentiment;

-- 7. Lưu kết quả ra file
STORE result_bai1 INTO 'file:///C:/Lab2/output_bai1' USING PigStorage('\t');