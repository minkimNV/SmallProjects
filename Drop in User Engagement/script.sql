-- 데이터 확인
SELECT * FROM tutorial.yammer_users users LIMIT 5;

SELECT * FROM tutorial.yammer_events events LIMIT 5;

SELECT * FROM tutorial.yammer_emails emails LIMIT 5;


-- 주간 활성 유저 WAU 확인
SELECT DATE_TRUNC('week', events.occurred_at) AS week
      , COUNT(DISTINCT user_id) AS weekly_active_users
FROM tutorial.yammer_events events
WHERE occurred_at BETWEEN '2014-04-28 00:00:00' AND '2014-08-25 23:59:59'
AND events.event_type = 'engagement'
GROUP BY week
ORDER BY week;


-- 일간 신규 가입자 현황
SELECT DATE_TRUNC('day', created_at) as signup_date
      , COUNT(user_id) as signup_users
      , COUNT(CASE WHEN activated_at IS NOT NULL then user_id ELSE NULL 
END) as activated_users
FROM tutorial.yammer_users users
WHERE created_at BETWEEN '2014-06-01 00:00:00' AND '2014-08-31 23:59:59'
GROUP BY signup_date;


-- 주간 신규 가입자 현황
SELECT DATE_TRUNC('week', created_at) as signup_week
      , COUNT(user_id) as signup_users
      , COUNT(CASE WHEN activated_at IS NOT NULL then user_id ELSE NULL 
END) as activated_users
FROM tutorial.yammer_users users
WHERE created_at BETWEEN '2014-06-01 00:00:00' AND '2014-08-31 23:59:59'
GROUP BY signup_week


-- 유지기간별로 인게이지먼트의 변화
SELECT DATE_TRUNC('week', j.occurred_at) AS "week"
      , AVG(j.months_at_event) AS "Average age during week"
      , COUNT(DISTINCT CASE WHEN j.user_months > 70 THEN j.user_id ELSE 
NULL END) AS "10+ weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 70 AND j.user_months >= 
63 THEN j.user_id ELSE NULL END) AS "9 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 63 AND j.user_months >= 
56 THEN j.user_id ELSE NULL END) AS "8 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 56 AND j.user_months >= 
49 THEN j.user_id ELSE NULL END) AS "7 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 49 AND j.user_months >= 
42 THEN j.user_id ELSE NULL END) AS "6 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 42 AND j.user_months >= 
35 THEN j.user_id ELSE NULL END) AS "5 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 35 AND j.user_months >= 
28 THEN j.user_id ELSE NULL END) AS "4 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 28 AND j.user_months >= 
21 THEN j.user_id ELSE NULL END) AS "3 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 21 AND j.user_months >= 
14 THEN j.user_id ELSE NULL END) AS "2 weeks"
      , COUNT(DISTINCT CASE WHEN j.user_months < 14 AND j.user_months >= 7 
THEN j.user_id ELSE NULL END) AS "1 week"
      , COUNT(DISTINCT CASE WHEN j.user_months < 7 THEN j.user_id ELSE 
NULL END) AS "Less than a week"
FROM (
      SELECT events.occurred_at
            , users.user_id
            , DATE_TRUNC('week', users.activated_at) AS activation_week
            , EXTRACT('day' FROM events.occurred_at - users.activated_at) 
AS months_at_event
            , EXTRACT('day' FROM '2014-09-01'::TIMESTAMP - 
users.activated_at) as user_months
      FROM tutorial.yammer_users users
      JOIN tutorial.yammer_events events
      ON events.user_id = users.user_id
      AND events.event_type = 'engagement'
      AND events.occurred_at BETWEEN '2014-04-28 00:00:00' AND '2014-08-31 
23:59:59'
      WHERE users.activated_at IS NOT NULL
      ) j
GROUP BY week
ORDER BY week;


-- 디바이스 종류 확인
SELECT device, COUNT(*) AS device_count
FROM tutorial.yammer_events events
WHERE events.event_type = 'engagement'
GROUP BY device
ORDER BY device_count


-- 디바이스별 WAU
SELECT DATE_TRUNC('week', events.occurred_at) AS week
      , COUNT(DISTINCT events.user_id) AS weekly_active_users
      , COUNT(DISTINCT CASE WHEN events.device IN ('ipad air','nexus 
7','ipad mini','nexus 10','kindle fire','windows surface',
       'samsumg galaxy tablet') THEN events.user_id ELSE NULL END) AS 
tablet
      , COUNT(DISTINCT CASE WHEN events.device IN ('iphone 5','samsung 
galaxy s4','nexus 5','iphone 5s','iphone 4s','nokia lumia 635',
       'htc one','samsung galaxy note','amazon fire phone') THEN 
events.user_id ELSE NULL END) AS phone
      , COUNT(DISTINCT CASE when events.device IN ('macbook pro','lenovo 
thinkpad','macbook air','dell inspiron notebook',
       'asus chromebook','dell inspiron desktop','acer aspire 
notebook','hp pavilion desktop','acer aspire desktop','mac mini') THEN 
events.user_id ELSE NULL END) AS computer
FROM tutorial.yammer_events events
WHERE events.event_type = 'engagement'
GROUP BY week
ORDER BY week;


-- 나라 종류 확인
SELECT *
FROM tutorial.yammer_events events
WHERE events.event_type = 'engagement'

SELECT location, COUNT(*) AS location_count
FROM tutorial.yammer_events events
WHERE events.event_type = 'engagement'
GROUP BY location
ORDER BY location ASC


-- 나라별 WAU 확인
SELECT DATE_TRUNC('week', events.occurred_at) AS week
      , COUNT(DISTINCT events.user_id) AS weekly_active_users
      , COUNT(DISTINCT CASE WHEN events.location IN ('Austria', 'Belgium', 
'Denmark', 'Finland', 'France', 'Germany', 'Greece', 'Ireland', 'Italy', 
'Netherlands', 'Norway', 'Poland', 'Portugal', 'Russia', 'Spain', 
'Sweden', 'Switzerland', 'United Kingdom') THEN events.user_id ELSE NULL 
END) AS "EU"
      , COUNT(DISTINCT CASE WHEN events.location IN ('Hong Kong', 'India', 
'Indonesia', 'Iran', 'Iraq', 'Israel', 'Japan', 'Korea', 'Malaysia', 
'Pakistan', 'Philippines', 'Saudi Arabia', 'Singapore', 'Taiwan', 
'Thailand', 'Turkey', 'United Arab Emirates') THEN events.user_id ELSE 
NULL END) AS "Asia"
      , COUNT(DISTINCT CASE WHEN events.location IN ('Egypt', 'Nigeria', 
'South Africa') THEN events.user_id ELSE NULL END) AS "Africa"
      , COUNT(DISTINCT CASE WHEN events.location IN ('Canada', 'United 
States', 'Mexico') THEN events.user_id ELSE NULL END) AS "North America"
      , COUNT(DISTINCT CASE WHEN events.location IN ('Argentina', 
'Brazil', 'Chile', 'Colombia', 'Venezuela') THEN events.user_id ELSE NULL 
END) AS "South America"
      , COUNT(DISTINCT CASE WHEN events.location IN ('Australia') THEN 
events.user_id ELSE NULL END) AS "Oceania"
FROM tutorial.yammer_events events
WHERE events.event_type = 'engagement'
GROUP BY week
ORDER BY week;


-- 이메일 액션별 WAU 확인
SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(CASE WHEN e.action = 'sent_weekly_digest' THEN e.user_id ELSE 
NULL END) AS weekly_emails,
       COUNT(CASE WHEN e.action = 'sent_reengagement_email' THEN e.user_id 
ELSE NULL END) AS reengagement_emails,
       COUNT(CASE WHEN e.action = 'email_open' THEN e.user_id ELSE NULL 
END) AS email_opens,
       COUNT(CASE WHEN e.action = 'email_clickthrough' THEN e.user_id ELSE 
NULL END) AS email_clickthroughs
  FROM tutorial.yammer_emails e
 GROUP BY week
 ORDER BY week;


-- 보내는 이메일 타입: 두 가지 (weekly_digest와 reengagement_email)
-- weekly digest email 같은 경우에는 일주일의 내용을 정리해서 보내주는 
이메일
-- reengagement email 는 비활성 유저들에게 보내는 이메일
-- 두 종류의 이메일을 열어봤다 (email_open) 또는 이메일 내의 링크를 
클릭했다 (email_clickthrough)는 로그는 어떤 이메일 타입에서 발생한 
액션인지 상세정보 부재
-- 따라서 테이블을 leftjoin

-- SELECT e1.user_id, e1.occurred_at, e1.action
--       , e2.user_id, e2.occurred_at, e2.action
-- FROM tutorial.yammer_emails e1
--       LEFT JOIN tutorial.yammer_emails e2 -- 해당 이메일에 대한 행동 
발생을 확인하기 위해 email 테이블 레프트 조인
--                 ON e2.occurred_at BETWEEN e1.occurred_at AND 
e1.occurred_at + INTERVAL '5 MINUTE' -- 이메일이 보내진 
발생시점(e1.occurred_at) 보다는 늦지만 5분 이내에
--                 AND e2.user_id = e1.user_id 
--                 AND e2.action = 'email_open' -- 이메일 클릭 행동이 
발생한 경우 검색
-- WHERE e1.occurred_at BETWEEN '2014-04-28 00:00:00' AND '2014-08-25 
23:59:59'
-- AND e1.action IN ('sent_weekly_digest', 'sent_reengagement_email')

-- 이렇게 하면 이메일이 보내진 시간과 이메일 종류, 이메일을 5분 내로 
열어본 경우의 액션 발생 시점과 이메일을 열었다는 액션에 대한 컬럼이 있는 
데이터프레임 출력

SELECT DATE_TRUNC('week', e1.occurred_at) AS week
      , COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e1.user_id 
else NULL END) AS weekly_digest_email
      , COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e2.user_id 
else NULL END) AS weekly_digest_email_open
      , COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e3.user_id 
else NULL END) AS weekly_digest_email_clickthrough
      , COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN 
e1.user_id else NULL END) AS reengagement_email
      , COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN 
e2.user_id else NULL END) AS reengagement_email_open
      , COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN 
e3.user_id else NULL END) AS reengagement_email_clickthrough
FROM tutorial.yammer_emails e1
      LEFT JOIN tutorial.yammer_emails e2 -- 해당 이메일에 대한 <이메일 
오픈> 행동 발생을 확인하기 위해 email 테이블 레프트 조인
                ON e2.occurred_at BETWEEN e1.occurred_at AND 
e1.occurred_at + INTERVAL '5 MINUTE'
                AND e2.user_id = e1.user_id 
                AND e2.action = 'email_open' -- 이메일이 보내진 
발생시점(e1.occurred_at) 보다는 늦지만 5분 이내에 발생한 email open 행동 
탐색
      LEFT JOIN tutorial.yammer_emails e3 -- 해당 이메일을 열어본 사람 
중에서  <이메일 내 링크 클릭> 행동 발생을 확인하기 위해 email 테이블 
레프트 조인
                ON e3.occurred_at BETWEEN e2.occurred_at AND 
e2.occurred_at + INTERVAL '5 MINUTE' 
                AND e3.user_id = e2.user_id 
                AND e3.action = 'email_clickthrough'
WHERE e1.occurred_at BETWEEN '2014-06-01 00:00:00' AND '2014-08-31 
23:59:59'
AND e1.action IN ('sent_weekly_digest', 'sent_reengagement_email')
GROUP BY week;
