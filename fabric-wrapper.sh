    #!/bin/sh
    # Wrapper script for running fabric non-interactively

    # Execute the real fabric binary, passing all arguments ($@)
    # and applying the necessary redirections.
    /usr/local/bin/fabric "$@" < /dev/null 2>&1

    # Exit with the exit code of the fabric command
    exit $?
    