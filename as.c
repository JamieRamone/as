/***********************************************************************************************************************************
 *
 *	as.c
 *
 * This file is an part of Mondo SysUtils package.
 *
 *	Copyright (C) 2020 Mondo Megagames.
 * 	Author: Jamie Ramone <sancombru@gmail.com>
 *	Date: 5-6-20
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>
 *
 **********************************************************************************************************************************/
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pwd.h>

#include <sys/types.h>

extern char	** environ;

static char	* command = NULL,
		* user = NULL;

static inline void print_help ( register const char * me )
{
	printf ( "Usage:\t%s user command\n\t%s <-?|-h|--help>\n\n", me, me );
	printf ( "   The second form prints this message. The first form runs the given command as the given user, by changing to that account and then\n" );
	printf ( "running a shell which then runs the given command. Running the command in a shell instead of directly invoking it allows it to been\n" );
	printf ( "enclosed in single quotes and still be able to expand shell patterns.\n\n" );
	printf ( "   This program is copyright (c) Jamie Ramone, Mondo Megagames (http://www.mondomegagames.epizy.com/). It is licensed\n" );
	printf ( "under the terms of the GNU General Public License, either version 3 or, if you prefer, a later version." );
};

static inline void process_arguments ( register const int arguments, register const char * argument [] )
{
	register int	arg = -1;
	register bool	criteria = false;

	criteria = ( arguments < 2 );

	if ( criteria ) {
		printf ( "Too few arguments. Run %s -? (or -h, or --help) for help on how to run this command.\n", argument [ 0 ] );
		exit ( -1 );
	}

	for ( arg = 1; arg < arguments; arg++ ) {
		criteria = ( strcmp ( argument [ arg ], "-?" ) == 0 );
		criteria = ( criteria || strcmp ( argument [ arg ], "-h" ) == 0 );
		criteria = ( criteria || strcmp ( argument [ arg ], "--help" ) == 0 );

		if ( criteria ) {
			print_help ( argument [ 0 ] );
			exit ( 0 );
		} else {
			switch ( arg ) {
				case 1:	user = (char *) argument [ arg ];
					break;
				case 2:	command = (char *) argument [ arg ];
			}
		}
	}

	if ( command == NULL ) {
		printf ( "Too few arguments. Run %s -? (or -h, or --help) for help on how to run this command.\n", argument [ 0 ] );
		exit ( -1 );
	}
};

static inline void run ( register const char * command, register const char * user, register const char * home )
{
	char	* arg [ 4 ] = { NULL },
		* env [ 4 ] = { NULL };
	char	new_env [ 4 ] [ 256 ] = {{ '\0' }};

	arg [ 0 ] = "-l";
	arg [ 1 ] = "-c";
	arg [ 2 ] = (char *) command;
	arg [ 3 ] = NULL;
	sprintf ( new_env [ 0 ], "HOME=%s", home );
	env [ 0 ] = new_env [ 0 ];
	sprintf ( new_env [ 1 ], "TERM=%s", getenv ( "TERM" ));
	env [ 1 ] = new_env [ 1 ];
	sprintf ( new_env [ 2 ], "PATH=/bin:/aux/bin" );
	env [ 2 ] = new_env [ 2 ];
	env [ 3 ] = NULL;
	execve ( "/bin/sh", arg, env );
	printf ( "Error ocurred trying to run command %s as user %s.\n", command, user );
};

int main ( register const int arguments, register const char * argument [] )
{
	register struct passwd	* entry = NULL;

	process_arguments ( arguments, argument );

	if ( getuid () != 0 ) {
		printf ( "This command can only be run by the system administrator.\n" );
		exit ( -1 );
	}

	setpwent ();
	entry = getpwent ();

	while ( entry != NULL && strcmp ( entry->pw_name, user ) != 0 ) {
		entry = getpwent ();
	}

	if ( entry == NULL ) {
		printf ( "Account %s not found, aborting...\n", user );
		exit ( -1 );
	}

	endpwent ();
	setuid ( entry->pw_uid );
	run ( command, user, entry->pw_dir );
};
