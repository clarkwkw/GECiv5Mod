Update Technologies SET GridY = GridY + 1;
Update Technologies SET GridX = GridX + 1 
	WHERE
		Era IN ('ERA_INDUSTRIAL', 'ERA_MODERN', 'ERA_POSTMODERN', 'ERA_FUTURE') 
		AND Type NOT IN ('TECH_CHEMISTRY', 'TECH_BIOLOGY');