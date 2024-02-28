CREATE OR REPLACE FUNCTION Schemas.insert_tb_employees()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare 
	next_hk_no INTEGER;
	cleaned_employee_id VARCHAR;
	combined_username VARCHAR;
BEGIN
  	-- Wrap the entire function body in a BEGIN...EXCEPTION block
    BEGIN
		IF TG_OP = 'INSERT' and new.workstatus = '1' then
	   
	  		-- Get the next value for hk_no directly in the assignment
	   		SELECT COALESCE(MAX(hk_employee_no::int), 0) + 1 INTO next_hk_no FROM facescan.attendance_user_map;
	   
	   		-- Replace non-alphanumeric characters with an empty string
	    	cleaned_employee_id := REGEXP_REPLACE(new.employeeid, '[^a-zA-Z0-9]', '', 'g');
	   
	   		-- Combine cleaned_employee_id and new.employee_name with a space in between
	   		combined_username := cleaned_employee_id || ' ' || new.email;
	    
	    	IF new.oldemployeeid IS NULL then
	   		
	    		insert into facescan.attendance_user_map(hk_employee_no,hk_employee_id,hk_employee_name, employee_id,employee_name,organization) 
	    		values(next_hk_no,cleaned_employee_id,combined_username,new.employeeid,new.email,new.companyshortname);
	    	
	    	ELSE
	    	
	     		update facescan.attendance_user_map
	     		set hk_employee_id = cleaned_employee_id,
	     			hk_employee_name = combined_username,
	     			employee_id = new.employeeid,
	     			employee_name = new.email,
	     			organization = new.companyshortname
	     		where 
	     			employee_id = new.oldemployeeid;
	    	
	    	END IF;
	     
	   END IF;
   	
	EXCEPTION
        WHEN others THEN
            -- Handle the exception here (replace RAISE NOTICE with your preferred error handling)
            RAISE NOTICE 'Error occurred: %', SQLERRM;
	
    END;
    
   RETURN NEW;
END;
$function$;