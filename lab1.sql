CREATE TABLE MyTable (
    id NUMBER,
    val NUMBER
);



DECLARE
    v_id NUMBER;
    v_val NUMBER;
BEGIN
    FOR i IN 1..10000 LOOP
        v_id := i;
        v_val := ROUND(DBMS_RANDOM.VALUE(1, 10000));
        INSERT INTO MyTable(id, val) VALUES (v_id, v_val);
    END LOOP;
    COMMIT;
END;




CREATE OR REPLACE FUNCTION check_even_odd_count RETURN VARCHAR2 IS
    v_even_count NUMBER := 0;
    v_odd_count NUMBER := 0;
BEGIN
    SELECT COUNT(CASE WHEN MOD(val, 2) = 0 THEN 1 END),
           COUNT(CASE WHEN MOD(val, 2) != 0 THEN 1 END)
    INTO v_even_count, v_odd_count
    FROM MyTable;

    IF v_even_count > v_odd_count THEN
        RETURN 'TRUE';
    ELSIF v_even_count < v_odd_count THEN
        RETURN 'FALSE';
    ELSE
        RETURN 'EQUAL';
    END IF;
END check_even_odd_count;




CREATE OR REPLACE FUNCTION generate_insert_statement(p_id NUMBER) RETURN VARCHAR2 IS
    v_val NUMBER;
    v_insert_statement VARCHAR2(1000);
BEGIN
  
    SELECT val INTO v_val
    FROM MyTable
    WHERE id = p_id;


    v_insert_statement := 'INSERT INTO MyTable(id, val) VALUES (' || p_id || ', ' || v_val || ');';

    DBMS_OUTPUT.PUT_LINE(v_insert_statement);
    RETURN v_insert_statement;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Строка с указанным ID не найдена в таблице.');
        RETURN NULL;
END generate_insert_statement;



CREATE OR REPLACE PROCEDURE insert_record(
    p_id NUMBER,
    p_val NUMBER
) IS
BEGIN
    INSERT INTO MyTable(id, val)
    VALUES (p_id, p_val);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Запись успешно добавлена.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении записи: ' || SQLERRM);
        ROLLBACK;
END insert_record;


CREATE OR REPLACE PROCEDURE update_record(
    p_id NUMBER,
    p_val NUMBER
) IS
BEGIN
    UPDATE MyTable
    SET val = p_val
    WHERE id = p_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Запись успешно обновлена.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Запись с указанным ID не найдена.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении записи: ' || SQLERRM);
        ROLLBACK;
END update_record;


CREATE OR REPLACE PROCEDURE delete_record(
    p_id NUMBER
) IS
BEGIN
    DELETE FROM MyTable
    WHERE id = p_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Запись успешно удалена.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Запись с указанным ID не найдена.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении записи: ' || SQLERRM);
        ROLLBACK;
END delete_record;



CREATE OR REPLACE FUNCTION calculate_annual_compensation(
    p_monthly_salary NUMBER,
    p_annual_bonus_percentage NUMBER
) RETURN NUMBER IS
    v_annual_compensation NUMBER;
BEGIN
    IF p_monthly_salary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Месячная зарплата должна быть положительным числом.');
    END IF;
    
    IF p_annual_bonus_percentage < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Процент годовых премиальных должен быть неотрицательным числом.');
    END IF;
    p_annual_bonus_percentage := p_annual_bonus_percentage / 100;
    v_annual_compensation := (1 + p_annual_bonus_percentage) * 12 * p_monthly_salary;
    RETURN v_annual_compensation;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Произошла ошибка: ' || SQLERRM);
END calculate_annual_compensation;