#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>



int main(int argc, const char** argv[])
{
    openlog("WriterDebug", 0, LOG_USER);

    if(argc < 3)
    {
        syslog(LOG_ERR, "Invalid number of args: %d", argc);

        return 1;
    }
    

    char* filePath = argv[1];
    char* stringToWrite = argv[2];
    
    
    FILE * file = fopen(filePath, "w");
    
    syslog(LOG_DEBUG, "Writing %s to %s", stringToWrite, filePath);
    fprintf(file, stringToWrite);

    
    return 0;
}
