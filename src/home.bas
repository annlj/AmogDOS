#include "/usr/local/include/freebasic/crt/linux/unistd.bi"
#include "/usr/local/include/freebasic/crt/linux/syslog.bi"
#include "file.bi"

CONST AS STRING lecture = "This is a command file for HOME, it's name is the only thing that matters, think of the folder it's in as a command list."
CONST AS STRING help_lecture = !"No command arguments. Usage:\n\n     home [argument]\n For more details, type ""home --help"", or read the manual page.\n"
CONST AS INTEGER MAX_LISTSIZE = 16

function RestoreConfigurations(where1 as integer, where2 as integer, destructive as integer) as integer 

    shell("chattr -R -i /home")

    dim as integer configrestorefilenumber = freefile

    if curdir <> "/home" or curdir <> "/home/commandstart" then
        chdir("/home/commandstart/")
    endif

    'If destructive, delete all files in commandstart before restoring the desired configurations.

    if destructive = 1 then

        dim as string filestodestroy = dir("*")

        for i as integer = 0 to MAX_LISTSIZE

            if filestodestroy <> "firstboot.home" then
                kill filestodestroy
            endif

            filestodestroy = dir()

            if filestodestroy = "" or filestodestroy = " " then
                exit for
            endif

        next

        filestodestroy = ""

    end if

    'restore the configurations.
    dim as string defaultcommands(0 to MAX_LISTSIZE)
    defaultcommands(0) = "0startx"

    for i as integer = where1 to where2 step 1
        
        if defaultcommands(i) = "" or defaultcommands(i) = "" then
            exit for
        endif

        if fileexists(defaultcommands(i)) = 0 then
            open defaultcommands(i) for output as #configrestorefilenumber
                print #configrestorefilenumber, lecture
            close #configrestorefilenumber
        endif

    next

    configrestorefilenumber = 0
    erase(defaultcommands)

    shell("chattr -R +i /home")
    chdir("/home/")
    return 1

end function

'Command argument check.
'Literally the first thing we take care of is removing features.
for i as integer = 0 to 4 step 1

    if instr(command(), "--userlecture") <> 0 then
        print("HOME does not support creating/editing users!")
        end 1
    endif

next

'Arguments relating to enabling and disabling X11

if instr(command(), "--startx false") then

    if fileexists("/home/commandstart/0startx") = 0 then
        print("X11 is already set to not start by default.")
        End
    else
        kill "/home/commandstart/0startx"
        End
    endif 
    
elseif instr(command(), "--startx true") then

    if fileexists("/home/commandstart/0startx") <> 0 then
        print("X11 is already set to start by default.")
        End
    else
        RestoreConfigurations(0,0,0)
        End
    endif

endif

'Arguments ralating to the autostartup

if instr(command(), "--startup") <> 0 then
    goto startup
elseif command() = "" or command() = " " or command() = 0 then
    print(help_lecture)
endif

End

startup:
'For now, we're just gonna check if the user wants us to start X11 on startup or not.

shell("chattr -R -i /home") 'no longer immutable

'Change our working directory to commandstart to retrieve our command list.
var chwd = chdir("/home/commandstart/")

'If we cannot do that however, we will recover it little by little.
if chwd = -1 then 

    openlog("HOME_STARTUP", LOG_PERROR, LOG_USER)
    syslog(LOG_NOTICE, "Could not change working directory, HOME will now create it.")

    var chwdhome = chdir("/home")
    if chwdhome = -1 then

        'If we cannot find the home directory, change the working directory to root.
        var chwdroot = chdir("/")

        if chwdroot = -1 then
            syslog(LOG_EMERG, "Root directory could not be located. HOME is patched, or the system is busted.")
            End 1
        endif 

        mkdir("home")
        chdir("/home")
        
    endif

    mkdir("commandstart")
    chdir("commandstart")
    RestoreConfigurations(0, MAX_LISTSIZE, 1)

    dim as integer recoveryfilenumber = freefile
    open "firstboot.home" for output as #recoveryfilenumber
        print #recoveryfilenumber, "0"
    close #recoveryfilenumber

    closelog()

endif

/' We check if the user has booted into the system for the first time. If they have booted in for
the first time, then we create our command files '/

dim as integer filenumberforhome = freefile
dim as ubyte isfirstboot

open "firstboot.home" for input as #filenumberforhome
    input #filenumberforhome, isfirstboot
close #filenumberforhome

if isfirstboot = 1 then
    RestoreConfigurations(0, MAX_LISTSIZE, 1)
endif

'Add all valid file names to a command queue to be batch executed later
dim as string commandqueue(0 to MAX_LISTSIZE)
dim as string filelist = dir("*")
for i as integer = 0 to MAX_LISTSIZE step 1

    if filelist = "" or filelist = " " then
        exit for
    else
        commandqueue(i) = filelist
    endif

    filelist = dir()

next

shell("chattr -R +i /home") 'Once again immutable.

'We do this now, because waiting for dir() is too slow
for i as integer = 0 to MAX_LISTSIZE step 1

    if commandqueue(i) <> "firstboot.home" then
        SLEEP 2500
    endif

    if commandqueue(i) = "" or commandqueue(i) = " " then

        exit for

    elseif commandqueue(i) <> "firstboot.home" then

        commandqueue(i) = right(commandqueue(i), len(commandqueue(i)) - 1)
        shell(commandqueue(i))

    endif

next