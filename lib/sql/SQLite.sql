-- SQLite
ALTER TABLE exercises RENAME COLUMN _id TO id;


DROP TABLE exercises;
DROP TABLE workout_records;


//db찾기
find ~/Library/Developer/CoreSimulator/Devices -name "health_app.db";