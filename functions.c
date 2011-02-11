/************************
 * String functions
 */
CLIPS *prependString(char *buffer, CLIPS *clips)
{
	char newText[strlen(clips->buffer) + strlen(buffer) + 1];
	strcpy(newText, buffer);
	strcat(newText, clips->buffer);
	return  al_clips( LITERAL, 0, 0, newText, strlen(newText)+1);
}
CLIPS *appendString(CLIPS *clips,char *buffer)
{
	char newText[strlen(clips->buffer) + strlen(buffer) + 1];
	strcpy(newText, clips->buffer);
	strcat(newText, buffer);
	return  al_clips( LITERAL, 0, 0, newText, strlen(newText)+1);
}
CLIPS *append2Strings(CLIPS *clips,char *buffer,char *buffer2)
{
	char newText[strlen(clips->buffer) + strlen(buffer) + strlen(buffer2) + 1];
	strcpy(newText, clips->buffer);
	strcat(newText, buffer);
	strcat(newText, buffer2);
	return  al_clips( LITERAL, 0, 0, newText, strlen(newText)+1);
}
CLIPS *prepend2Strings(char *buffer1, char *buffer2, CLIPS *clips)
{
	char newText[strlen(clips->buffer) + strlen(buffer1) + strlen(buffer2) + 1];
	strcpy(newText, buffer1);
	strcat(newText, buffer2);
	strcat(newText, clips->buffer);
	return  al_clips( LITERAL, 0, 0, newText, strlen(newText)+1);

}
CLIPS *prepend3Strings(char *buffer1, char *buffer2, char *buffer3, CLIPS *clips)
{
	char newText[strlen(clips->buffer) + strlen(buffer1) + strlen(buffer2)+ strlen(buffer3) + 1];
	strcpy(newText, buffer1);
	strcat(newText, buffer2);
	strcat(newText, buffer3);
	strcat(newText, clips->buffer);
	return  al_clips( LITERAL, 0, 0, newText, strlen(newText)+1);
}
/*******************
 * Language Functions
 */
CLIPS *createModifier(int token)
{
	char newText[strlen(tokens[token % TYPEDEF])+1];
	strcpy(newText,tokens[token % TYPEDEF]);
	int i;
	for(i = 0; newText[ i ]; i++)
	    newText[i] = tolower(newText[ i ]);

	return al_clips(token,0,0,newText,strlen(newText)+1);
}
CLIPS *createLeftBracket() {
	return  al_clips( LITERAL, 0, 0, "{", 2);
}
CLIPS *createRightBracket() {
	return  al_clips( LITERAL, 0, 0, "}", 2);
}
CLIPS *createEquals()
{
	return al_clips(LITERAL,0,0,"=",2);
}
CLIPS *createSemicolon()
{
	return al_clips(LITERAL,0,0,";",2);
}
CLIPS *createFromString(char *c)
{
	return al_clips(LITERAL,0,0,c,strlen(c)+1);
}
CLIPS *createFromStringWithToken(char *c,int token)
{
	return al_clips(token,0,0,c,strlen(c)+1);
}
void maskClips(CLIPS *clips,int mask)
{
	while(clips)
	{
		clips->mask |= mask;
		clips = clips->next;
	}
}
