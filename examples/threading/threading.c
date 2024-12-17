#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
// #define DEBUG_LOG(msg,...)
#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter

    struct thread_data* arg_p = (struct thread_data *) thread_param;
    
    /* wait befor lock */
    usleep(arg_p->wait_to_obtain_ms * 1000);

    unsigned int rc = pthread_mutex_lock(arg_p->mutex);
    if(rc)
    {
        DEBUG_LOG("#Error: mutex lock fail.");
        arg_p->thread_complete_success = false;
    }

    usleep(arg_p->wait_to_release_ms * 1000);

    rc = pthread_mutex_unlock(arg_p->mutex);
    if(rc)
    {
        DEBUG_LOG("#Error: mutex unlock fail.");
        arg_p->thread_complete_success = false;
    }



    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */

    /* allocate memory for thread_data */
    struct thread_data *thread_data_p = (struct thread_data*) malloc(sizeof (struct thread_data));

    thread_data_p->mutex = mutex;
    thread_data_p->wait_to_obtain_ms = wait_to_obtain_ms;
    thread_data_p->wait_to_release_ms = wait_to_release_ms;
    thread_data_p->thread_complete_success = true;

    int err = pthread_create(thread, NULL, threadfunc, thread_data_p);

    return err? false: true;
}

