USE pizza_runner
go
DROP FUNCTION IF EXISTS dbo.udf_get_numbers;
go
CREATE FUNCTION udf_get_numbers(@str VARCHAR(20))
RETURNS float
BEGIN
	DECLARE @notNbCharIndex INT;
	SET @notNbCharIndex  = PATINDEX('%[^0-9.]%',@str)-1;
	IF @notNbCharIndex > 0 
		SET @str = substring(@str,1,@notNbCharIndex)
	return CAST(@str AS FLOAT);
END;
go
SELECT dbo.udf_get_numbers(duration), duration from runner_orders
