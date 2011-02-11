/*******************************************************************************
 *
 *	ansi_c audit routines
 *	the only types supported by the ansi_c compiler:
 *
 *	Input type1, type2:		Return type:
 *	VOID, NUL			CHAR
 *	CHAR, NUL			CHAR
 *	INT, NUL			INT
 *	UNSIGNED, CHAR			UNSIGNED_CHAR
 *	UNSIGNED, INT			UNSIGNED_INT
 *	UNSIGNED_CHAR, NUL		UNSIGNED_CHAR
 *	UNSIGNED_INT, NUL		UNSIGNED_INT
 *
 *	also support typedef char identifier or typedef int identifier 
 *
 *	TYPEDEF, CHAR			TYPEDEF_CHAR
 *	TYPEDEF, INT			TYPEDEF_INT
 *
 ******************************************************************************/
/*
 *	audit the type specifiers
 *	only support TYPEDEF CHAR or INT or
 *	support VOID, [UNSIGNED] CHAR or INT - everything to one byte CHAR
		$$.token = audit_declaration_specifiers( $1.token, 0);
		$$.token = audit_declaration_specifiers( $1.token, $2.token);
 */
int	audit_declaration_specifiers( int type1, int type2)
{
	switch( type1)
	{
	case VOID:
		if( ! type2)
			return CHAR;
		break;
	case CHAR:
		if( ! type2)
			return CHAR;
		break;
	case INT:
		if( ! type2)
			return INT;
		break;
	case UNSIGNED:
		switch( type2)
		{
		case CHAR:
			return UNSIGNED_CHAR;
		case INT:
			return UNSIGNED_INT;
		}
		break;
	case UNSIGNED_CHAR:
		if( ! type2)
			return UNSIGNED_CHAR;
		break;
	case UNSIGNED_INT:
		if( ! type2)
			return UNSIGNED_INT;
		break;
	case TYPEDEF:
		switch( type2)
		{
		case CHAR:
			return TYPEDEF_CHAR;
		case INT:
			return TYPEDEF_INT;
		}
		break;
	}
	fprintf( stderr, "Error: unsupported data type: %s %s\n", tokens[ type1], tokens[ type2]);
	data.errors++;
	return CHAR;
}

/*******************************************************************************
 *
 *	typedef table routines
 *
 ******************************************************************************/
/*
 *	print the typedef table
 */
void	print_typedef_table( void)
{
	if( data.typedef_table)
	{
		printf( "typedef table:\n");
		print_clips_list( data.typedef_table);
	}
}

/*
 *	find the identifier in the typedef table linked list 
 */
CLIPS	*find_typedef( char *text, int length)
{
	CLIPS	*lists;
/*
 *	search the clips list using the buffer length and string compare to match
 */
	for( lists = data.typedef_table; lists; lists = lists->next)
	{
		if( lists->length == length && ! strcmp( lists->buffer, text))
			return( lists);
	}
	return( lists);
}

/*
 *	type an identifier in typedef table
		$$.token = typedef_declaration( $1.token, $2.clips);
 */
CLIPS	*typedef_declaration( int type_specifier, CLIPS *identifier)
{
	CLIPS	*clips;
	int	type;
/*
 *	first search for same identifier string
 */
	clips = find_typedef( identifier->buffer, identifier->length);
	if( clips)
	{
		fprintf( stderr, "Error: typedef already defined for: %s\n", clips->buffer);
		data.errors++;
		return( identifier);
	}
	switch( type_specifier)
	{
	case TYPEDEF_CHAR:
		identifier->token = CHAR;
		break;
	case TYPEDEF_INT:
		identifier->token = INT;
		break;
	default:
		fprintf( stderr, "Warning typedef not supported for: %s\n", clips->buffer);
		data.warnings++;
		return( identifier);
	}
/*
 *	attach it to the head of the typedef table list (LIFO)
 */
	identifier->next = data.typedef_table;
	data.typedef_table = identifier;
/*
 *	return 
 */
	return( (CLIPS*)0);
}
