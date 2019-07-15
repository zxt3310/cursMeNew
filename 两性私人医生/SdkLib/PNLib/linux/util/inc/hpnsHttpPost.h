

#include <unistd.h> 
#include <stdlib.h> 
#include <stdio.h> 
#include <string.h> 
#include <ctype.h> 
#include <signal.h> 
#include <fcntl.h> 
#include <sys/types.h> 
#include <sys/stat.h> 
#include <sys/socket.h> 
#include <netinet/in.h> 
#include <netdb.h> 

#ifdef USE_SSL 
#include <openssl/ssl.h> 
#endif 

#include "Md5.h"

//#define pTrace(arg...) printf(arg)

/* Forwards. */ 
//static void usage(); 
static char* postURL( char* url, char* referer, char* user_agent, char* auth_token, int ncookies, char** cookies, char** args, int argc ); 
static char* postUrlAuth( char* url, char* referer, char* user_agent, char* auth_token, int ncookies, char** cookies, char** args, int argc, char* key ); 
static char* postURLbyParts( int protocol, char* host, unsigned short port, char* file, char* referer, char* user_agent, char* auth_token, int ncookies, char** cookies, char** args, int argc, int authFlag, char* key ); 
static int open_client_socket( char* hostname, unsigned short port ); 
static void show_error( char* cause ); 
//static void sigcatch( int sig ); 
static void strencode( char* to, char* from ); 
static int b64_encode( unsigned char* ptr, int len, char* space, int size ); 
static void* malloc_check( size_t size ); 
static void check( void* ptr ); 
static off_t file_bytes( const char* filename ); 
static int file_copy( const char* filename, char* buf ); 


/* Globals. */ 
static char* argv0;
static char* url; 
static int verbose; 

/* Protocol symbols. */ 
#define PROTO_HTTP 0 
#ifdef USE_SSL 
#define PROTO_HTTPS 1 
#endif 

/* Header FSM states. */ 
#define HDST_BOL 0 
#define HDST_TEXT 1 
#define HDST_LF 2 
#define HDST_CR 3 
#define HDST_CRLF 4 
#define HDST_CRLFCR 5 

#define MAX_COOKIES 20 


/*int 
main( int argc, char** argv ) 
{ 
int argn; 
char* referer; 
char* user_agent; 
char* auth_token; 
int ncookies; 
char* cookies[MAX_COOKIES]; 

argv0 = argv[0]; 
argn = 1; 
timeout = 60; 
referer = (char*) 0; 
user_agent = "http_post"; 
auth_token = (char*) 0; 
ncookies = 0; 
verbose = 0; 
while ( argn < argc && argv[argn][0] == '-' && argv[argn][1] != '\0' ) 
{ 
if ( strcmp( argv[argn], "-t" ) == 0 && argn + 1 < argc ) 
{ 
++argn; 
timeout = atoi( argv[argn] ); 
} 
else if ( strcmp( argv[argn], "-r" ) == 0 && argn + 1 < argc ) 
{ 
++argn; 
referer = argv[argn]; 
} 
else if ( strcmp( argv[argn], "-u" ) == 0 && argn + 1 < argc ) 
{ 
++argn; 
user_agent = argv[argn]; 
} 
else if ( strcmp( argv[argn], "-a" ) == 0 && argn + 1 < argc ) 
{ 
++argn; 
auth_token = argv[argn]; 
} 
else if ( strcmp( argv[argn], "-c" ) == 0 && argn + 1 < argc ) 
{ 
if ( ncookies >= MAX_COOKIES ) 
{ 
(void) fprintf( stderr, "%s: too many cookies\n", argv0 ); 
exit( 1 ); 
} 
++argn; 
cookies[ncookies++] = argv[argn]; 
} 
else if ( strcmp( argv[argn], "-v" ) == 0 ) 
verbose = 1; 
else 
usage(); 
++argn; 
} 
if ( argn >= argc ) 
usage(); 
url = argv[argn]; 
++argn; 

(void) signal( SIGALRM, sigcatch ); 
postURL( url, referer, user_agent, auth_token, ncookies, cookies, &(argv[argn]), argc - argn ); 

exit( 0 ); 
} 
*/ 

/*static void 
usage() 
{ 
(void) fprintf( stderr, "usage: %s [-c cookie] [-t timeout] [-r referer] [-u user-agent] [-a username:password] [-v] url\n", argv0 ); 
exit( 1 ); 
}*/ 



static char * urlencode(char const *s, int len, int *new_length)
{
    //printf( s);
    //printf("\n");

    unsigned char const *from, *end;
	unsigned char *start, *to;
	unsigned char c;
	
    from = s;
    end = s + len;
    start = to = (unsigned char *) malloc(3 * len + 1);

    unsigned char hexchars[] = "0123456789ABCDEF";

    while (from < end) {
        c = *from++;

        if (c == ' ') {
            *to++ = '+';
        } else if ((c < '0' && c != '-' && c != '.')
                   ||(c < 'A' && c > '9')
                   ||(c > 'Z' && c < 'a' && c != '_')
                   ||(c > 'z')) {
            to[0] = '%';
            to[1] = hexchars[c >> 4];
            to[2] = hexchars[c & 15];
            to += 3;
        } else {
            *to++ = c;
        }
    }
    *to = 0;
    if (new_length) {
        *new_length = to - start;
    }
    return (char *) start;

}


static int urldecode(char *str, int len)
{
    char *dest = str;
    char *data = str;

    int value;
    int c;

    while (len--) {
        if (*data == '+') {
        *dest = ' ';
        }
        else if (*data == '%' && len >= 2 && isxdigit((int) *(data + 1))
                 && isxdigit((int) *(data + 2)))
        {

            c = ((unsigned char *)(data+1))[0];
            if (isupper(c))
                c = tolower(c);
            value = (c >= '0' && c <= '9' ? c - '0' : c - 'a' + 10) * 16;
            c = ((unsigned char *)(data+1))[1];
            if (isupper(c))
                c = tolower(c);
            value += c >= '0' && c <= '9' ? c - '0' : c - 'a' + 10;

            *dest = (char)value ;
            data += 2;
            len -= 2;
        } else {
            *dest = *data;
        }
        data++;
        dest++;
    }
    *dest = '\0';
    return dest - str;
}



/* url must be of the form http://host-name[:port]/file-name */ 
static char* 
postURL( char* url, char* referer, char* user_agent, char* auth_token, int ncookies, char** cookies, char** args, int argc) 
{ 
char* s; 
int protocol; 
char host[2000]; 
int host_len; 
unsigned short port; 
char* file = 0; 
char* http = "http://"; 
int http_len = strlen( http ); 
#ifdef USE_SSL 
char* https = "https://"; 
int https_len = strlen( https ); 
#endif /* USE_SSL */ 
int proto_len; 

if ( url == (char*) 0 ) 
{ 
(void) fprintf( stderr, "%s: null URL\n", argv0 ); 
exit( 1 ); 
} 
if ( strncmp( http, url, http_len ) == 0 ) 
{ 
proto_len = http_len; 
protocol = PROTO_HTTP; 
} 
#ifdef USE_SSL 
else if ( strncmp( https, url, https_len ) == 0 ) 
{ 
proto_len = https_len; 
protocol = PROTO_HTTPS; 
} 
#endif /* USE_SSL */ 
else 
{ 
(void) fprintf( stderr, "%s: non-http URL\n", argv0 ); 
exit( 1 ); 
} 

/* Get the host name. */ 
for ( s = url + proto_len; *s != '\0' && *s != ':' && *s != '/'; ++s ) 
; 
host_len = s - url; 
host_len -= proto_len; 
strncpy( host, url + proto_len, host_len ); 
host[host_len] = '\0'; 

/* Get port number. */ 
if ( *s == ':' ) 
{ 
port = (unsigned short) atoi( ++s ); 
while ( *s != '\0' && *s != '/' ) 
++s; 
} 
else 
#ifdef USE_SSL 
if ( protocol == PROTO_HTTPS ) 
port = 443; 
else 
port = 80; 
#else 
port = 80; 
#endif 

/* Get the file name. */ 
if ( *s == '\0' ) 
file = "/"; 
else 
file = s; 

return postURLbyParts( protocol, host, port, file, referer, user_agent, auth_token, ncookies, cookies, args, argc, 0, NULL); 
} 

/* url must be of the form http://host-name[:port]/file-name */ 
static char* 
postUrlAuth( char* url, char* referer, char* user_agent, char* auth_token, int ncookies, char** cookies, char** args, int argc, char* key ) 
{ 
char* s; 
int protocol; 
char host[2000]; 
int host_len; 
unsigned short port; 
char* file = 0; 
char* http = "http://"; 
int http_len = strlen( http ); 
#ifdef USE_SSL 
char* https = "https://"; 
int https_len = strlen( https ); 
#endif /* USE_SSL */ 
int proto_len; 

if ( url == (char*) 0 ) 
{ 
(void) fprintf( stderr, "%s: null URL\n", argv0 ); 
exit( 1 ); 
} 
if ( strncmp( http, url, http_len ) == 0 ) 
{ 
proto_len = http_len; 
protocol = PROTO_HTTP; 
} 
#ifdef USE_SSL 
else if ( strncmp( https, url, https_len ) == 0 ) 
{ 
proto_len = https_len; 
protocol = PROTO_HTTPS; 
} 
#endif /* USE_SSL */ 
else 
{ 
(void) fprintf( stderr, "%s: non-http URL\n", argv0 ); 
exit( 1 ); 
} 

/* Get the host name. */ 
for ( s = url + proto_len; *s != '\0' && *s != ':' && *s != '/'; ++s ) 
; 
host_len = s - url; 
host_len -= proto_len; 
strncpy( host, url + proto_len, host_len ); 
host[host_len] = '\0'; 

/* Get port number. */ 
if ( *s == ':' ) 
{ 
port = (unsigned short) atoi( ++s ); 
while ( *s != '\0' && *s != '/' ) 
++s; 
} 
else 
#ifdef USE_SSL 
if ( protocol == PROTO_HTTPS ) 
port = 443; 
else 
port = 80; 
#else 
port = 80; 
#endif 

/* Get the file name. */ 
if ( *s == '\0' ) 
file = "/"; 
else 
file = s; 

return postURLbyParts( protocol, host, port, file, referer, user_agent, auth_token, ncookies, cookies, args, argc, 1, key ); 
} 


static char* 
postURLbyParts( int protocol, char* host, unsigned short port, char* file, char* referer, char* user_agent, char* auth_token, int ncookies, char** cookies, char** args, int argc, int authFlag, char* key ) 
{ 
	int sockfd; 
#ifdef USE_SSL 
	SSL_CTX* ssl_ctx; 
	SSL* ssl; 
#endif 
	char  head_buf[20000]; 
	char* ret_buf = malloc(20000); 
	char* pos; 
	int max_arg, total_bytes; 
	int multipart, next_arg_is_file; 
	static const char* const sep = "http_post-content-separator"; 
	char* data_buf; 
	char* enc_buf; 
	int head_bytes, data_bytes, i, header_state; 
	char* eq; 

	pos = ret_buf; 
	bzero(ret_buf, 20000); 

	//(void) alarm( timeout ); 
	sockfd = open_client_socket( host, port ); 
	if(sockfd <= 0)
	{
		return NULL;
	}

#ifdef USE_SSL 
	if ( protocol == PROTO_HTTPS ) 
	{ 
		/* Make SSL connection. */ 
		int r; 
		SSL_load_error_strings(); 
		SSLeay_add_ssl_algorithms(); 
		ssl_ctx = SSL_CTX_new( SSLv23_client_method() ); 
		ssl = SSL_new( ssl_ctx ); 
		SSL_set_fd( ssl, sockfd ); 
		r = SSL_connect( ssl ); 
		if ( r <= 0 ) 
		{ 
			(void) fprintf( 
			stderr, "%s: %s - SSL connection failed - %d\n", 
			argv0, url, r ); 
			ERR_print_errors_fp( stderr ); 
			return NULL;
			//exit( 1 ); 
		} 
	} 
#endif 

	/* Run through the arguments and figure out the total and max sizes, 
	** then allocate enough space. 
	*/ 
	multipart = 0; 
	total_bytes = max_arg = 0; 
	next_arg_is_file = 0; 
	for ( i = 0; i < argc ; ++i ) 
	{ 
		int l = strlen( args[i] ); 
		if ( strcmp( args[i], "-f" ) == 0 ) 
		{ 
			multipart = 1; 
			next_arg_is_file = 1; 
			continue; 
		} 
		total_bytes += l; 
		if ( l > max_arg ) 
			max_arg = l; 
		if ( next_arg_is_file ) 
		{ 
			eq = strchr( args[i], '=' ); 
			if ( eq == (char*) 0 ) 
			{ 
				(void) fprintf( stderr, "%s: missing filename\n", argv0 ); 
				return NULL;//exit( 1 ); 
			} 
			else 
			{ 
				++eq; 
				total_bytes += file_bytes( eq ); 
			} 
			next_arg_is_file = 0; 
		} 
	} 
	if ( multipart ) 
	{ 
		for ( i = 0; i < argc ; ++i ) 
			total_bytes += strlen( sep ) * 2 + 100; 
		total_bytes += strlen( sep ) * 2; 
	} 
	else 
	{ 
		total_bytes *= 4; 
		enc_buf = (char*) malloc_check( max_arg * 4 ); 
	} 
	data_buf = (char*) malloc_check( total_bytes ); 

	/* Encode the POST data. */ 
	if ( multipart ) 
	{ 
		next_arg_is_file = 0; 
		data_bytes = 0; 
		for ( i = 0; i < argc ; ++i ) 
		{ 
			if ( strcmp( args[i], "-f" ) == 0 ) 
			{ 
				next_arg_is_file = 1; 
				continue; 
			} 
			eq = strchr( args[i], '=' ); 
			if ( eq == (char*) 0 ) 
				data_bytes += sprintf( &data_buf[data_bytes], "--%s\r\nContent-Disposition: form-data\r\n\r\n%s\r\n", sep, args[i] ); 
			else 
			{ 
				*eq++ = '\0'; 
				if ( next_arg_is_file ) 
				{ 
					data_bytes += sprintf( &data_buf[data_bytes], "--%s\r\nContent-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\n\r\n", sep, args[i], eq ); 
					data_bytes += file_copy( eq, &data_buf[data_bytes] ); 
					data_bytes += sprintf( &data_buf[data_bytes], "\r\n" ); 
					next_arg_is_file = 0; 
				} 
				else 
					data_bytes += sprintf( &data_buf[data_bytes], "--%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n", sep, args[i], eq ); 
			} 
		} 
		data_bytes += sprintf( &data_buf[data_bytes], "--%s--\r\n", sep ); 
	} 
	else 
	{ 
		/* Not multipart. */ 
		data_bytes = 0; 
		for ( i = 0; i < argc ; ++i ) 
		{ 
			if ( data_bytes > 0 ) 
				data_bytes += sprintf( &data_buf[data_bytes], "&" ); 
			eq = strchr( args[i], '=' ); 
			if ( eq == (char*) 0 ) 
			{ 
			//strencode( enc_buf, args[i] ); 
			//data_bytes += sprintf( &data_buf[data_bytes], "%s", enc_buf ); 
			data_bytes += sprintf(&data_buf[data_bytes], "%s", args[i]); 
			} 
			else 
			{ 
			*eq++ = '\0'; 
			strencode( enc_buf, args[i] ); 
			data_bytes += sprintf( &data_buf[data_bytes], "%s=", enc_buf ); 
			strencode( enc_buf, eq ); 
			data_bytes += sprintf( &data_buf[data_bytes], "%s", enc_buf ); 
			} 
		} 

		if(authFlag)
		{
			char digest[16] = {0};
			mir_md5_state_t state;
			
			char* pBuf = calloc(1, data_bytes + strlen(key) + 1);
			strcpy(pBuf, data_buf);
			strcat(pBuf, key);

			md5_init(&state);
			md5_append(&state, pBuf, strlen(pBuf));
			md5_finish(&state, digest);
			
			free(pBuf);

			char hexStr[32] = {0};
			int k = 0;
			int m = 0;
			for(k = 0; k < 16; k++)
			{
				sprintf(hexStr + m, "%02x", (unsigned char)digest[k]);
				m += 2;
			}

			if ( data_bytes > 0 ) 
				data_bytes += sprintf( &data_buf[data_bytes], "&" ); 

			data_bytes += sprintf( &data_buf[data_bytes], "auth=%s", hexStr );
		}

			
	} 

	
	//encoder
	int en_bytes = 0;
	char *enstr = urlencode(data_buf, strlen(data_buf), &en_bytes);
	data_bytes = strlen(enstr);


	/* Build request buffer, starting with the POST. */ 
	//(void) alarm( timeout ); 
	head_bytes = snprintf( head_buf, sizeof(head_buf), "POST %s HTTP/1.0\r\n", file ); 
	/* HTTP/1.1 host header - some servers want it even in HTTP/1.0. */ 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Host: %s\r\n", host ); 
	/* Content-length. */ 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Content-Length: %d\r\n", strlen(data_buf) ); 
	if ( referer != (char*) 0 ) 
	/* Referer. */ 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Referer: %s\r\n", referer ); 
	/* User-agent. */ 
	if(user_agent != (char*) 0) 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "User-Agent: %s\r\n", user_agent ); 
	/* Content-type. */ 
	if ( multipart ) 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Content-type: multipart/form-data; boundary=\"%s\"\r\n", sep ); 
	else 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Content-type: text/html\r\n" ); 
	/* Fixed headers. */ 
	//head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Accept: */*\r\n" ); 
	//head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Accept-Encoding: gzip, compress\r\n" ); 
	//head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Accept-Language: en\r\n" ); 
	//head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Accept-Charset: iso-8859-1,*,utf-8\r\n" ); 
	if ( auth_token != (char*) 0 ) 
	{ 
	/* Basic Auth info. */ 
	char token_buf[1000]; 
	//token_buf[b64_encode( auth_token, strlen( auth_token ), token_buf, sizeof(token_buf) )] = '\0'; 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Authorization: Digest %s\r\n", auth_token ); 
	} 
	/* Cookies. */ 
	//for ( i = 0; i < ncookies; ++i ) 
	// head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "Cookie: %s\r\n", cookies[i] ); 
	/* Blank line. */ 

	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "\r\n" ); 
	head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "%s", data_buf); 
	//head_bytes += snprintf( &head_buf[head_bytes], sizeof(head_buf) - head_bytes, "%s", enstr); 
	/* Now actually send it. */ 
	printf("no en request:%s\n", head_buf);

	free(enstr);


	/*
#ifdef USE_SSL 
	if ( protocol == PROTO_HTTPS ) 
	(void) SSL_write( ssl, head_buf, head_bytes ); 
	else 
	(void) write( sockfd, head_buf, head_bytes ); 
#else 
	(void) write( sockfd, head_buf, head_bytes ); 
#endif 
	*/
	/* And send the POST data too. */ 
#ifdef USE_SSL 
	if ( protocol == PROTO_HTTPS ) 
	(void) SSL_write( ssl, head_buf, head_bytes ); 
	else 
	(void) write( sockfd, head_buf, head_bytes ); 
#else 
	(void) write( sockfd, head_buf, head_bytes ); 
#endif 

	printf("send:%s", head_buf); 
	/* Get lines until a blank one. */ 
	//(void) alarm( timeout ); 
	header_state = HDST_BOL; 
	for (;;) 
	{ 
#ifdef USE_SSL 
		if ( protocol == PROTO_HTTPS ) 
			head_bytes = SSL_read( ssl, head_buf, sizeof(head_buf) ); 
		else 
			head_bytes = read( sockfd, head_buf, sizeof(head_buf) ); 
#else 
			head_bytes = read( sockfd, head_buf, sizeof(head_buf) ); 
#endif 
		if ( head_bytes <= 0 ) 
		{
			break; 
		}

		//printf("\n ret:%s", head_buf); 
		for ( i = 0; i < head_bytes; ++i ) 
		{ 
			if ( verbose ) 
			{ 
				//(void) write( 1, &head_buf[i], 1 ); 
				*pos = head_buf[i]; 
				pos++; 
			} 
			switch ( header_state ) 
			{ 
			case HDST_BOL: 
				switch ( head_buf[i] ) 
				{ 
				case '\n': header_state = HDST_LF; break; 
				case '\r': header_state = HDST_CR; break; 
				default: header_state = HDST_TEXT; break; 
				} 
				break; 
				
			case HDST_TEXT: 
				switch ( head_buf[i] ) 
				{ 
				case '\n': header_state = HDST_LF; break; 
				case '\r': header_state = HDST_CR; break; 
				} 
				break; 

			case HDST_LF: 
				switch ( head_buf[i] ) 
				{ 
				case '\n': goto end_of_headers; 
				case '\r': header_state = HDST_CR; break; 
				default: header_state = HDST_TEXT; break; 
				} 
				break; 

			case HDST_CR: 
				switch ( head_buf[i] ) 
				{ 
				case '\n': header_state = HDST_CRLF; break; 
				case '\r': goto end_of_headers; 
				default: header_state = HDST_TEXT; break; 
				} 
				break; 

			case HDST_CRLF: 
				switch ( head_buf[i] ) 
				{ 
				case '\n': goto end_of_headers; 
				case '\r': header_state = HDST_CRLFCR; break; 
				default: header_state = HDST_TEXT; break; 
				} 
				break; 

			case HDST_CRLFCR: 
				switch ( head_buf[i] ) 
				{ 
				case '\n': case '\r': goto end_of_headers; 
				default: header_state = HDST_TEXT; break; 
				} 
				break; 
			} 
		} 
	} 
end_of_headers: 
	/* Dump out the rest of the headers buffer. */ 
	++i; 
	//(void) write( 1, &head_buf[i], head_bytes - i ); 
	if(head_bytes > i)
	{
		memcpy(pos, &head_buf[i], head_bytes - i); 
		pos += head_bytes - i; 
	}
	
	/* Copy the data. */ 
	/*for (;;) 
	{ 
	(void) alarm( timeout ); 
#ifdef USE_SSL 
	if ( protocol == PROTO_HTTPS ) 
	head_bytes = SSL_read( ssl, head_buf, sizeof(head_buf) ); 
	else 
	head_bytes = read( sockfd, head_buf, sizeof(head_buf) ); 
#else 
	head_bytes = read( sockfd, head_buf, sizeof(head_buf) ); 
#endif 
	if ( head_bytes == 0 ) 
	break; 
	if ( head_bytes < 0 ) 
	show_error( "read" ); 
	//(void) write( 1, head_buf, head_bytes ); 
	memcpy(pos, head_buf, head_bytes); 
	pos += head_bytes; 
	}*/ 
	*pos = 0; 
#ifdef USE_SSL 
	if ( protocol == PROTO_HTTPS ) 
	{ 
		SSL_free( ssl ); 
		SSL_CTX_free( ssl_ctx ); 
	} 
#endif 
	(void) close( sockfd ); 

	memcpy(cookies, head_buf, 20000);
	return ret_buf; 
} 


#if defined(AF_INET6) && defined(IN6_IS_ADDR_V4MAPPED) 
#define USE_IPV6 
#endif 

static int 
open_client_socket( char* hostname, unsigned short port ) 
{ 
#ifdef USE_IPV6 
struct addrinfo hints; 
char portstr[50]; 
int gaierr; 
struct addrinfo* ai; 
struct addrinfo* ai2; 
struct addrinfo* aiv4; 
struct addrinfo* aiv6; 
struct sockaddr_in6 sa; 
#else /* USE_IPV6 */ 
struct hostent *he; 
struct sockaddr_in sa; 
#endif /* USE_IPV6 */ 
int sa_len, sock_family, sock_type, sock_protocol; 
int sockfd; 

(void) memset( (void*) &sa, 0, sizeof(sa) ); 

#ifdef USE_IPV6 

(void) memset( &hints, 0, sizeof(hints) ); 
hints.ai_family = PF_UNSPEC; 
hints.ai_socktype = SOCK_STREAM; 
(void) sprintf( portstr, "%d", (int) port ); 
if ( (gaierr = getaddrinfo( hostname, portstr, &hints, &ai )) != 0 ) 
{ 
(void) fprintf( 
stderr, "%s: getaddrinfo %s - %s\n", argv0, hostname, 
gai_strerror( gaierr ) ); 
exit( 1 ); 
} 

/* Find the first IPv4 and IPv6 entries. */ 
aiv4 = (struct addrinfo*) 0; 
aiv6 = (struct addrinfo*) 0; 
for ( ai2 = ai; ai2 != (struct addrinfo*) 0; ai2 = ai2->ai_next ) 
{ 
switch ( ai2->ai_family ) 
{ 
case AF_INET: 
if ( aiv4 == (struct addrinfo*) 0 ) 
aiv4 = ai2; 
break; 
case AF_INET6: 
if ( aiv6 == (struct addrinfo*) 0 ) 
aiv6 = ai2; 
break; 
} 
} 

/* If there's an IPv4 address, use that, otherwise try IPv6. */ 
if ( aiv4 != (struct addrinfo*) 0 ) 
{ 
if ( sizeof(sa) < aiv4->ai_addrlen ) 
{ 
(void) fprintf( 
stderr, "%s - sockaddr too small (%lu < %lu)\n", 
hostname, (unsigned long) sizeof(sa), 
(unsigned long) aiv4->ai_addrlen ); 
exit( 1 ); 
} 
sock_family = aiv4->ai_family; 
sock_type = aiv4->ai_socktype; 
sock_protocol = aiv4->ai_protocol; 
sa_len = aiv4->ai_addrlen; 
(void) memmove( &sa, aiv4->ai_addr, sa_len ); 
goto ok; 
} 
if ( aiv6 != (struct addrinfo*) 0 ) 
{ 
if ( sizeof(sa) < aiv6->ai_addrlen ) 
{ 
(void) fprintf( 
stderr, "%s - sockaddr too small (%lu < %lu)\n", 
hostname, (unsigned long) sizeof(sa), 
(unsigned long) aiv6->ai_addrlen ); 
exit( 1 ); 
} 
sock_family = aiv6->ai_family; 
sock_type = aiv6->ai_socktype; 
sock_protocol = aiv6->ai_protocol; 
sa_len = aiv6->ai_addrlen; 
(void) memmove( &sa, aiv6->ai_addr, sa_len ); 
goto ok; 
} 

(void) fprintf( 
stderr, "%s: no valid address found for host %s\n", argv0, hostname ); 
exit( 1 ); 

ok: 
freeaddrinfo( ai ); 

#else /* USE_IPV6 */ 

he = gethostbyname( hostname ); 
if ( he == (struct hostent*) 0 ) 
{ 
(void) fprintf( stderr, "%s: unknown host - %s\n", argv0, hostname ); 
exit( 1 ); 
} 
sock_family = sa.sin_family = he->h_addrtype; 
sock_type = SOCK_STREAM; 
sock_protocol = 0; 
sa_len = sizeof(sa); 
(void) memmove( &sa.sin_addr, he->h_addr, he->h_length ); 
sa.sin_port = htons( port ); 

#endif /* USE_IPV6 */ 

sockfd = socket( sock_family, sock_type, sock_protocol ); 
if ( sockfd < 0 ) 
show_error( "socket" ); 

if ( connect( sockfd, (struct sockaddr*) &sa, sa_len ) < 0 ) 
show_error( "connect" ); 

return sockfd; 
} 


static void 
show_error( char* cause ) 
{ 
char buf[5000]; 
(void) sprintf( buf, "%s: %s - %s", argv0, url, cause ); 
perror( buf ); 
//exit( 1 ); 
} 


/*static void 
sigcatch( int sig ) 
{ 
(void) fprintf( stderr, "%s: %s - timed out\n", argv0, url ); 
exit( 1 ); 
}*/ 


static void 
strencode( char* to, char* from ) 
{ 
int tolen; 

for ( tolen = 0; *from != '\0'; ++from ) 
{ 
if ( isalnum(*from) || strchr( "/_.", *from ) != (char*) 0 ) 
{ 
*to = *from; 
++to; 
++tolen; 
} 
else 
{ 
(void) sprintf( to, "%c%02x", '%', (unsigned char)*from ); 
to += 3; 
tolen += 3; 
} 
} 
*to = '\0'; 
} 


/* Base-64 encoding. This encodes binary data as printable ASCII characters. 
** Three 8-bit binary bytes are turned into four 6-bit values, like so: 
** 
** [11111111] [22222222] [33333333] 
** 
** [111111] [112222] [222233] [333333] 
** 
** Then the 6-bit values are represented using the characters "A-Za-z0-9+/". 
*/ 

static char b64_encode_table[64] = { 
'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', /* 0-7 */ 
'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', /* 8-15 */ 
'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', /* 16-23 */ 
'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', /* 24-31 */ 
'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', /* 32-39 */ 
'o', 'p', 'q', 'r', 's', 't', 'u', 'v', /* 40-47 */ 
'w', 'x', 'y', 'z', '0', '1', '2', '3', /* 48-55 */ 
'4', '5', '6', '7', '8', '9', '+', '/' /* 56-63 */ 
}; 

static int b64_decode_table[256] = { 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 00-0F */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 10-1F */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63, /* 20-2F */ 
52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1, /* 30-3F */ 
-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14, /* 40-4F */ 
15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1, /* 50-5F */ 
-1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40, /* 60-6F */ 
41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1, /* 70-7F */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 80-8F */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 90-9F */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* A0-AF */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* B0-BF */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* C0-CF */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* D0-DF */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* E0-EF */ 
-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 /* F0-FF */ 
}; 

/* Do base-64 encoding on a hunk of bytes. Return the actual number of 
** bytes generated. Base-64 encoding takes up 4/3 the space of the original, 
** plus a bit for end-padding. 3/2+5 gives a safe margin. 
*/ 
static int 
b64_encode( unsigned char* ptr, int len, char* space, int size ) 
{ 
int ptr_idx, space_idx, phase; 
char c; 

space_idx = 0; 
phase = 0; 
for ( ptr_idx = 0; ptr_idx < len; ++ptr_idx ) 
{ 
switch ( phase ) 
{ 
case 0: 
c = b64_encode_table[ptr[ptr_idx] >> 2]; 
if ( space_idx < size ) 
space[space_idx++] = c; 
c = b64_encode_table[( ptr[ptr_idx] & 0x3 ) << 4]; 
if ( space_idx < size ) 
space[space_idx++] = c; 
++phase; 
break; 
case 1: 
space[space_idx - 1] = 
b64_encode_table[ 
b64_decode_table[(int) space[space_idx - 1]] | 
( ptr[ptr_idx] >> 4 ) ]; 
c = b64_encode_table[( ptr[ptr_idx] & 0xf ) << 2]; 
if ( space_idx < size ) 
space[space_idx++] = c; 
++phase; 
break; 
case 2: 
space[space_idx - 1] = 
b64_encode_table[ 
b64_decode_table[(int) space[space_idx - 1]] | 
( ptr[ptr_idx] >> 6 ) ]; 
c = b64_encode_table[ptr[ptr_idx] & 0x3f]; 
if ( space_idx < size ) 
space[space_idx++] = c; 
phase = 0; 
break; 
} 
} 
/* Pad with ='s. */ 
while ( phase++ < 3 ) 
if ( space_idx < size ) 
space[space_idx++] = '='; 
return space_idx; 
} 


static void* 
malloc_check( size_t size ) 
{ 
void* ptr = malloc( size ); 
check( ptr ); 
return ptr; 
} 


static void 
check( void* ptr ) 
{ 
if ( ptr == (void*) 0 ) 
{ 
(void) fprintf( stderr, "%s: out of memory\n", argv0 ); 
exit( 1 ); 
} 
} 


static off_t 
file_bytes( const char* filename ) 
{ 
struct stat sb; 

if ( stat( filename, &sb ) < 0 ) 
{ 
perror( filename ); 
exit( 1 ); 
} 
return sb.st_size; 
} 


static int 
file_copy( const char* filename, char* buf ) 
{ 
int fd; 
struct stat sb; 
off_t bytes; 

fd = open( filename, O_RDONLY ); 
if ( fd == -1 ) 
{ 
perror( filename ); 
exit( -1 ); 
} 
if ( fstat( fd, &sb ) != 0 ) 
{ 
perror( filename ); 
exit( -1 ); 
} 
bytes = sb.st_size; 
if ( read( fd, buf, bytes ) != bytes ) 
{ 
perror( filename ); 
exit( -1 ); 
} 
(void) close( fd ); 
return bytes; 
} 


