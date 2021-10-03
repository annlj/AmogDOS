#include "/usr/local/include/freebasic/crt/linux/unistd.bi"
#include "/usr/local/include/freebasic/crt/linux/syslog.bi"
#include "file.bi"

CONST lecture = "This is a command file for HOME, it's name is the only thing that matters, think of the folder it's in as a command list."

'Literally the first thing we take care of is removing features.
dim as string usercommands(4)

    usercommands(0) = "useradd"
    usercommands(1) = "userdel"
    usercommands(2) = "usermod"
    usercommands(3) = "passwd"
    usercommands(4) = "chage"

for i as integer = 0 to 4 step 1

    if instr(command(), usercommands(i)) <> 0 then

        print("HOME does not support creating/editing users!")
        end 1
    
    endif

next

'For now, we're just gonna check if the user wants us to start X11 on startup or not.
var unlockh = shell("chattr -R -i /home") 'no longer immutable
if unlockh = -1 then

    openlog("HOME_STARTUP", LOG_PERROR, LOG_USER)
    syslog(LOG_CRIT, "Initialization process could not acquire a shell, startup processes are misconfigured, or the system is unuseable.")
    closelog()

endif

'Change our working directory to commandstart to retrieve our command list.
var chwd = chdir("/home/commandstart/")
if chwd = -1 then 'If we cannot do that however, we will recover it little by little.

    openlog("HOME_STARTUP", LOG_PERROR, LOG_USER)
    syslog(LOG_NOTICE, "Could not change working directory, HOME will now create it.")

    var chwdhome = chdir("/home")
    if chwdhome = -1 then

        syslog(LOG_NOTICE, "You think you're funny aren't you, testing me? Fine, i'll recreate the whole /home directory structure for you.")
        
        var chwdroot = chdir("/")
        if chwdroot = -1 then

            syslog(LOG_EMERG, "Could not find root directory. Either i am patched, or the system is unuseable")
            closelog()
            End 1
        
        endif 

        mkdir("home")
        var chwdnhome = chdir("/home")

        if chwdnhome = -1 then

            syslog(LOG_CRIT, "I cannot navigate to the directory that i created in /home, quitting...")
            closelog()
            End 1

        endif
        
    endif

    mkdir("commandstart")
    exec("/usr/bin/touch", "startx")

    dim as integer recoveryfilenumber = freefile
    open "firstboot.home" for output as #recoveryfilenumber
        print #recoveryfilenumber, "0"
    close #recoveryfilenumber

    closelog()

endif

dim as integer filenumberforhome = freefile
dim as ubyte isfirstboot

/' We check if the user has booted into the system for the first time. If they have booted in for
the first time, then we create our command files '/

open "firstboot.home" for input as #filenumberforhome

    input #filenumberforhome, isfirstboot

close #filenumberforhome

if isfirstboot = 1 then

    open "startx" for output as #filenumberforhome
        print #filenumberforhome, lecture 'Lecture has no effect, just teaches users not to snoop
    close #filenumberforhome

endif

'Add all valid file names to a command queue to be batch executed later
dim as string commandqueue(16)
dim as string filelist = dir("*")
for i as integer = 0 to 16 step 1

    if filelist = "" or filelist = " " then

        exit for

    else

        commandqueue(i) = filelist
    
    endif

    filelist = dir()

next

shell("chattr -R +i /home") 'Once again immutable.

'We do this now, because waiting for dir() is too slow
for i as integer = 0 to 16 step 1

    if commandqueue(i) = "" or commandqueue(i) = " " then

        exit for

    else

        shell(commandqueue(i))

    endif

next