CREATE TABLE cloneeventtest (
  counter INT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  seconds_elapsed INT
);

CREATE TABLE statusflag (
  delflag VARCHAR(10) DEFAULT 0 NOT NULL
);

INSERT INTO statusflag (delflag) VALUES (0);

CREATE TABLE eventerrormsg (
  event_id INT NOT NULL,
  error_message VARCHAR(255) NOT NULL,
  timestamp TIMESTAMP NOT NULL
);


CREATE OR REPLACE FUNCTION cloneeventproc()
RETURNS void AS $$
DECLARE	
  ev_counter INT;
  start_counter_flag INT;
  ev_timestamp TIMESTAMP;
  ev_seconds_elapsed INT;
  a INT;
BEGIN
  
    -- Getthe start counter flag.
    SELECT delflag INTO start_counter_flag FROM statusflag;
   
    a :=5;

    -- If the start counter flag is set to 1, then start the counter.
    IF start_counter_flag = 0 OR  start_counter_flag = 1 THEN
      LOOP
          a :=a-1;
            -- Increment the event ID.
            SELECT COALESCE(MAX(cloneeventtest.counter), 0) + 1 INTO ev_counter FROM cloneeventtest;

            -- Set the seconds elapsed to 0.
            ev_seconds_elapsed := 0;
            SELECT COALESCE(MAX(cloneeventtest.seconds_elapsed), 0) + 60 INTO ev_seconds_elapsed FROM cloneeventtest;

            PERFORM  pg_sleep(60);
            -- Get the current date and time. 
            SELECT clock_timestamp ( )  INTO ev_timestamp;  

            -- Insert a new row into the cloneeventtest table.
            INSERT INTO cloneeventtest (counter, timestamp, seconds_elapsed)
            VALUES (ev_counter, ev_timestamp, ev_seconds_elapsed);
        EXIT WHEN a < 1;
      END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;
