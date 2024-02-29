create trigger insert_tb_employees_trigger 
    after insert
    on Schemas.tb_employees 
    for each row 
    execute function Schemas.insert_tb_employees()
    --execute PROCEDURE Schemas.insert_tb_employees()