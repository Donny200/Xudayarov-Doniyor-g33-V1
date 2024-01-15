/*
 Xudayarov Doniyor
 Variant 1

 https://drawsql.app/teams/doniyor-4/diagrams/hospital
 */


CREATE TABLE "Doctors"(
                          "id" BIGINT NOT NULL,
                          "name" VARCHAR(255) NOT NULL,
                          "phone" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "Doctors" ADD PRIMARY KEY("id");
CREATE TABLE "Patient"(
                          "id" bigserial NOT NULL,
                          "first_name" VARCHAR(255) NOT NULL,
                          "registration_date" DATE NOT NULL,
                          "phone" VARCHAR(255) NOT NULL,
                          "appointment_date" DATE NOT NULL,
                          "last_name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "Patient" ADD PRIMARY KEY("id");
CREATE TABLE "Appointment"(
                              "id" bigserial NOT NULL,
                              "patient_id" BIGINT NOT NULL,
                              "staff_id" BIGINT NOT NULL,
                              "appointment_date" DATE NOT NULL
);

ALTER TABLE "Appointment" ADD PRIMARY KEY("id");

CREATE TABLE "Recording"(
                            "id" bigserial NOT NULL,
                            "notebook" VARCHAR(255) NOT NULL,
                            "phone" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "Recording" ADD PRIMARY KEY("id");
CREATE TABLE "Admin"(
                        "id" bigserial NOT NULL,
                        "patient_id" bigserial NOT NULL,
                        "doctors_id" bigserial NOT NULL,
                        "recording_id" bigserial NOT NULL,
                        "appointment_id" bigserial NOT NULL
);
ALTER TABLE
    "Admin" ADD PRIMARY KEY("id");
ALTER TABLE
    "Admin" ADD CONSTRAINT "admin_doctors_id_foreign" FOREIGN KEY("doctors_id") REFERENCES "Doctors"("id");
ALTER TABLE
    "Admin" ADD CONSTRAINT "admin_recording_id_foreign" FOREIGN KEY("recording_id") REFERENCES "Recording"("id");
ALTER TABLE
    "Admin" ADD CONSTRAINT "admin_appointment_id_foreign" FOREIGN KEY("appointment_id") REFERENCES "Appointment"("id");
ALTER TABLE
    "Admin" ADD CONSTRAINT "admin_patient_id_foreign" FOREIGN KEY("patient_id") REFERENCES "Patient"("id");


INSERT INTO "Doctors" (id, name, phone) VALUES
                                            (1, 'Dr. Bob', '+998901234567'),
                                            (2, 'Dr. Jon', '+998975678934');

INSERT INTO "Patient" ("first_name", "last_name", "registration_date", "phone", "appointment_date") VALUES
                                                                                                        (1,'Doniyor', 'Xudayarov', '2024-01-15', '+998904903007', '2024-01-20'),
                                                                                                        (2,'Sanjar', 'Surname', '2024-01-16', '+998977440230', '2024-01-21');

INSERT INTO "Recording" ("notebook", "phone") VALUES
                                                  (1,'Patient Notes 1', '998904903007'),
                                                  (2,'Patient Notes 2', '998977440230');

INSERT INTO "Admin" ("patient_id", "doctors_id", "recording_id", "appointment_id") VALUES
                                                                                       (1, 1, 1, 1),
                                                                                       (2, 2, 2, 2);


-- Assuming records with IDs 1 and 1 exist in the Patient and Doctors tables.
INSERT INTO "Appointment" ("patient_id", "staff_id", "appointment_date") VALUES
    (1, 2, '2024-03-16');

SELECT * FROM "Doctors";
SELECT * FROM "Patient";
SELECT * FROM "Recording";
SELECT * FROM "Admin";
SELECT * from "Appointment";


--Task 1:
CREATE OR REPLACE FUNCTION fn_search_patient_by_name(
    in p_name varchar(255)
)
    RETURNS TABLE(
                     p_first_name varchar(255),
                     p_last_name varchar(255)
                 )
    LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
SELECT "first_name", "last_name" FROM "Patient"
WHERE "first_name" ILIKE '%'||p_name||'%' OR "last_name" ILIKE '%'||p_name||'%';
END
$$;

SELECT * FROM fn_search_patient_by_name('i');

-- Task 2:
CREATE OR REPLACE PROCEDURE pr_schedule_appointment(
    p_id bigint,
    s_id bigint,
    a_date date
)
    LANGUAGE plpgsql
AS $$
BEGIN
INSERT INTO "Appointment"("patient_id", "staff_id", "appointment_date")
VALUES (p_id, s_id, a_date);
END
$$;

CALL pr_schedule_appointment(p_id := 3, s_id := 3, a_date := date '2024-03-16');

SELECT * FROM "Appointment";

-- Task 3:
CREATE OR REPLACE VIEW appointments_for_today AS
SELECT * FROM "Appointment"
WHERE "appointment_date" = current_date;

SELECT * FROM appointments_for_today;

-- Task 4:
CREATE MATERIALIZED VIEW every_patient_appointment_count_last_month AS
SELECT
    "first_name" || ' ' || "last_name" AS patient,
    COUNT(a."id") AS count_of_appointments,
    EXTRACT(MONTH FROM a."appointment_date") AS month,
    EXTRACT(YEAR FROM a."appointment_date") AS year
FROM "Appointment" a
    JOIN "Patient" p ON p."id" = a."patient_id"
WHERE EXTRACT(MONTH FROM a."appointment_date") = EXTRACT(MONTH FROM current_date) - 1
GROUP BY patient, month, year;

REFRESH MATERIALIZED VIEW every_patient_appointment_count_last_month;

SELECT * FROM every_patient_appointment_count_last_month;
