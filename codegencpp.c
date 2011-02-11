CLIPS *classParams;
CLIPS *pointers;
CLIPS *mainMethod; //Main should always be at the end, if it calls other functions that need to be defined before it!

void code_generator_cpp_prefix( void)
{
	time_t	t;
	time( &t);

	printf("/*\n");
	printf("Author: Bryan Marty <bxm156@case.edu>\n");
	printf("Generated: %s", ctime( &t));
	printf("*/\n");
	printf("#include <iostream>\n");
	printf("#include <string>\n");
	printf("\n");
	printf("using namespace std;\n\n");

}
void handleLiterals(CLIPS *clips)
{
	if(strcmp(clips->buffer,"{") == 0)
	{
		printf("{\n");
		return;
	}
	if(strcmp(clips->buffer,"}") == 0)
	{
		printf("}\n");
		return;
	}
	if(strcmp(clips->buffer,";") == 0 && !(clips->mask & MASK_NOLF))
	{
		printf(";\n");
		return;
	}
	if(strcmp(clips->buffer,"};") == 0)
		{
			printf("};\n");
			return;
		}
	printf("%s",clips->buffer);

}
void printFormattedClip(CLIPS *clips)
{
	switch(clips->token)
	{
	case LITERAL:
		handleLiterals(clips);
		break;
	default:
		if(strcmp(clips->next->buffer,",") == 0)
		{
			printf("%s",clips->buffer);
		} else if (clips->next->token == OP_INC || clips->next->token == OP_DEC || clips->token == OP_INC || clips->token == OP_DEC){
			printf("%s",clips->buffer);
		} else {
			printf("%s ",clips->buffer);
		}
	}
}
CLIPS *handlePackageStatement(CLIPS *c1)
{
	/* method created in case we want to handle some type of package
	 * recongnition, but unlikely
	 */
	if(c1)
		de_clips_list(c1);
	return createFromString("");
}
CLIPS *handleImportStatement(CLIPS *c1, CLIPS *c2)
{
	//may use this method to check for c++ libraries to import
	//based on java ones, otheriwse.. its useless
	if(c1)
	de_clips_list(c1);
	if(c2)
	de_clips_list(c2);
	return createFromString("");
}
CLIPS *combineClips(CLIPS *clips_list)
{
	CLIPS *c = createFromString("");
	while(clips_list)
	{
		CLIPS *new;
		if(strcmp(clips_list->buffer,"{") == 0) {
			new = appendString(c,"{\n");
		}	else if(strcmp(clips_list->buffer,"}") == 0) {
			new = appendString(c,"}\n");
		} else if(strcmp(clips_list->buffer,";") == 0) {
			new = appendString(c,";\n");
		} else {
			new = append2Strings(c," ",clips_list->buffer);
		}
		de_clips(c);
		c = new;
		clips_list = clips_list->next;
	}
	return c;
}
CLIPS *processClassDeclaration(CLIPS *clips) {
		printf("class %s",clips->buffer);
		CLIPS *start = classParams;
		while(clips->next->mask & MASK_CLASSDEF)
		{
			clips = clips->next;
			printFormattedClip(clips);
		}
		if(strcmp(clips->next->buffer,"{") == 0)
		{
			printf("{\n");
			clips = clips->next; //eat
			CLIPS *params = classParams;
			printf("public:\n");
			while(params)
			{
				if(params->token == PUBLIC) {
					printf("%s \n",params->buffer);
				}
				params = params->next;
			}
			printf("private:\n");
			params = classParams;
			while(params)
			{
				if(params->token == PRIVATE) {
					printf("%s \n",params->buffer);
				}
				params = params->next;
			}
		}

		de_clips_list(start);
		return clips;

}
CLIPS *createMain(CLIPS *body){
		if(!classParams)
		{
			 classParams = createFromString("");
		}
		//printf("main Found!");
		CLIPS *c = createFromStringWithToken("int",INT);
		CLIPS *main = createFromString("main");
		CLIPS *param = createFromString("(int argc, char *argv[])");
		CLIPS *startBody = body;
		while(body->next)
		{
			if(body->token == RETURN)
			{
				if(strcmp(body->next->buffer,";") == 0)
				{
					CLIPS *c = createFromString("0");
					c->next = body->next;
					body->next = c;
					break;
				}
			}
			body = body->next;
		}
		CLIPS *final = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c,main),param),startBody);
		mainMethod = final;
		CLIPS *params = createFromString("");
		params->token = PUBLIC;
		classParams = clips_tail_to_head(params,classParams);
		return createFromString("");
}
int containsToken(CLIPS *list,int stoken)
{
	while(list)
	{
		if(list->token == stoken)
		{
			return 1;
		}
		list = list->next;
	}
	return 0;
}
int processMethod(CLIPS *Modifiers,CLIPS *TypeSpecifier, CLIPS *MethodDeclarator, CLIPS *Throws, CLIPS *MethodBody)
{
	if(!classParams)
		{
			classParams = createFromString("");
		}
		int isStatic = 0;
		CLIPS *end = createFromString(";");
		CLIPS *c = combineClips(TypeSpecifier);
		CLIPS *d = combineClips(MethodDeclarator);
		CLIPS *e = clips_tail_to_head(clips_tail_to_head(c,d),end);
		if(containsToken(Modifiers,STATIC))
		{
			CLIPS *s = createFromStringWithToken("static",STATIC);
			e = clips_tail_to_head(s,e);
			isStatic = 1;
		}


		CLIPS *params = combineClips(e);
		de_clips_list(e);
		//de_clips(end);
		params->token = PUBLIC;
		if(containsToken(Modifiers,PRIVATE)) {
			params->token = PRIVATE;
		}

		clips_tail_to_head(classParams,params);
		return isStatic;
}

void addClassParam(CLIPS *clip_list)
{
	if(!classParams)
	{
		classParams = createFromString("");
	}
	int token = PUBLIC;
	while(clip_list->token == PUBLIC || clip_list->token == PRIVATE )
	{
		token = clip_list->token;
		clip_list = clip_list->next;
	}
	CLIPS *params = combineClips(clip_list);
	params->token = token;
	clips_tail_to_head(classParams,params);
}
CLIPS *processPrintLine(CLIPS *param)
{
	CLIPS *c1 = createFromString("cout << ");
	CLIPS *c2 = createFromString(" << endl");
	return clips_tail_to_head(clips_tail_to_head(c1,param),c2);
}

CLIPS *auditForPointer(CLIPS *ident, CLIPS *list)
{
	if(!pointers)
	{
		pointers = createFromString("");
	}
	while(list)
	{
		if(list->token == NEW)
		{
			CLIPS *c = createFromString("*");
			CLIPS *p = createFromString(ident->buffer);
			clips_tail_to_head(pointers,p);
			return clips_tail_to_head(c,ident);
 		}
		list = list->next;
	}

	return ident;
}
CLIPS *auditForArrow(CLIPS *name,CLIPS *ident)
{
	CLIPS *p;
	p = createFromString(".");
	if(pointers)
	{
		CLIPS *currentP = pointers;
		while(currentP)
			{
				if(strcmp(currentP->buffer,name->buffer) == 0)
				{
				//	printf("Comparing.. %s  vs   %s \n",name->buffer,currentP->buffer);
					//We have a possible pointer!
					de_clips(p);
					p = createFromString("->");
					break;
				}
				currentP = currentP->next;
			}
	}
	CLIPS *final = prepend2Strings(name->buffer,p->buffer,ident);
	de_clips_list(name);
	de_clips(p);
	de_clips(ident);
	return final;
}
CLIPS *auditIdentifier(CLIPS *ident)
{
	if(strcmp(ident->buffer,"String") == 0) {
		de_clips(ident);
		CLIPS *c = createFromString("string ");
		return c;
	}
	return ident;
}
void code_generator_cpp(CLIPS *clips_list)
{
#ifdef YYDEBUG
	if (IS_FLAGS_DEBUG(data.flags))
	{
		printf("Clips List:\n");
		print_clips_list(clips_list);
		printf("Class Params:\n");
		print_clips_list(classParams);
	}
	#endif

	/* Init some stuff */
	/* Do some post processing */
	/*generate header */
	code_generator_cpp_prefix();

	CLIPS *clips = clips_tail_to_head(clips_list,mainMethod);
	while(clips)
	{
		/*if(clips->mask & MASK_METHOD)
		{
			clips = processMethodDelcaration(clips);
			continue;
		}*/

		switch(clips->token) {
		case CLASS:
			clips = processClassDeclaration(clips);
			clips = clips->next;
			break;
		default:
			printFormattedClip(clips);
			clips = clips->next;
		}
	}
	printf("\n");

	//de_methodList_list(mL);
	de_clips_list(clips_list);
	de_clips_list(pointers);

}

void code_generator_instr_test( void)
{
	return;
}
