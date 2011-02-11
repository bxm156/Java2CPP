/*******************************************************************************
 *
 *	more clips routines
 *
 ******************************************************************************/
/*
 *	link the tail of first linked list to second linked list
 */
CLIPS	*clips_tail_to_head( CLIPS *head1, CLIPS *head2)
{
	CLIPS	*lists;
/*
 *	check if head1 exist else return head2
 */
	if( head1)
	{
		lists = end_clips( head1);
		lists->next = head2;
		return( head1);
	}
	return( head2);
}

/*******************************************************************************
 *
 *	symbol table routines
 *
 ******************************************************************************/
/*
 *	print the symbol table
 */
void	print_symbol_table( void)
{
	printf( "symbol table:\n");
	print_clips_list( data.symbol_table);
}

/*
 *	find the identifier in the symbol table linked list at this level
 */
CLIPS	*find_symbol( int level, char *text, int length)
{
	CLIPS	*lists;
/*
 *	search the clips list using the buffer length and string compare to match
 */
	for( lists = data.symbol_table; lists; lists = lists->next)
	{
		if( lists->level < level)
			return( (CLIPS*)0);
		if( lists->length == length && ! strcmp( lists->buffer, text))
			return( lists);
	}
	return( lists);
}

/*
 *	create a symbol table entry unless one already exists 
 */
void	create_symbol( int type, unsigned char value, char *buffer, int length)
{
	
	CLIPS	*clips;
/*
 *	first search for same identifier string
 */
	clips = find_symbol( data.level, buffer, length);
/*
 *	update symbol type entry or make new symbol table entry
 */
	if( clips)
	{
		if( 0 < type)
			clips->token = type;
		if( 0 < value)
			clips->value = value;
		return;
	}
	clips = al_clips( type, value, 0, buffer, length);
	clips->level = data.level;
/*
 *	attach it to the head of the symbol table list (LIFO)
 */
	clips->next = data.symbol_table;
	data.symbol_table = clips;
	return;
}

/*******************************************************************************
 *
 *	symbol parser production routines
 *
 ******************************************************************************/
/*
 *	type an identifier in symbol table
		$$.clips = symbol_declaration( $1.token, $2.clips);
 */
CLIPS	*symbol_declaration( int type_specifier, CLIPS *init_declarator_list)
{
	CLIPS	*lists;
/*
 *	can be a list of identifiers
 */
	for( lists = init_declarator_list; lists; lists = lists->next)
	{
/*
 *	create a symbol with this type
 */
		create_symbol( type_specifier, 0, lists->buffer, lists->length);
	}
/*
 *	return init_declarator_list linked list
 */
	return( init_declarator_list);
}

/*
 *	update the value from last identifier and attach the clip
		$$.clips = symbol_init_declarator_list( $1.clips, $3.clips);
 */
CLIPS	*symbol_init_declarator_list( CLIPS *init_declarator_list, CLIPS *init_declarator)
{
	CLIPS	*lists;
/*
 *	can be a list of identifiers
 */
	for( lists = init_declarator_list; lists; lists = lists->next)
	{
/*
 *	create a symbol with this value
 */
		create_symbol( 0, init_declarator->value, lists->buffer, lists->length);
	}
/*
 *	link in the last init_declarator clip, return head of list
 */
	clips_tail_to_head( init_declarator_list, init_declarator);
	return( init_declarator_list);
}

/*
 *	update a value of an identifier in symbol table
		$$.clips = symbol_init_declarator( $1.clips, $3.clips);
 */
CLIPS	*symbol_init_declarator( CLIPS *declarator, CLIPS *initializer)
{
	CLIPS	*lists;
/*
 *	can be a list of identifiers
 */
	for( lists = declarator; lists; lists = lists->next)
	{
/*
 *	create a symbol with this value and copy it to identifier list
 */
		create_symbol( 0, initializer->value, lists->buffer, lists->length);
		lists->value = initializer->value;
	}
/*
 *	free the initializer linked list
 */
	de_clips_list( initializer);
	return( declarator);
}

/*
 *	new symbol table identifiers at this level
		symbol_left_bracket();
 */
void	symbol_left_bracket( void)
{
/*
 *	increment the symbol table level
 */
	data.level++;
	return;
}

/*
 *	pop symbol table identifiers at this level
		symbol_right_bracket();
 */
void	symbol_right_bracket( void)
{
	CLIPS	*clips;
/*
 *	print the complete symbol table before poping symbols off
 */
#ifdef	YYDEBUG
	if( IS_FLAGS_SYMBOL( data.flags))
	{
		printf( "pop symbol table level: %d\n", data.level);
		print_symbol_table();
	}
#endif
/*
 *	check and remove all clips above level
 */
	for( clips = data.symbol_table; clips; clips = data.symbol_table)
	{
		if( clips->level < data.level)
			break;
		data.symbol_table = clips->next;
		de_clips( clips);
	}
/*
 *	decrement the symbol table level
 */
	data.level--;
	return;
}

