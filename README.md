# PS Gem
A gem for interacting with the **p**rocess **s**tatus utility on unix systems.

### Getting information on a specific process

    [proc1,proc2] = PS.pid(1234,321)

or for shorthand

    proc1 = PS(1234)
    process_list = [proc1,proc2] = PS(1234,321)

### Finding process based on name

    process_list = PS(/Firefox.app/)

### Finding process based on attached port

To return any processes attached to port 80.

    process_list = PS(':80')

## Process

Processes have methods for every value listed in `ps -L` with `%` aliased to `pct`. The method `mem` was added which gives the megabytes of memory used by the process. The method `kill!(sig="INT")` was also added to send a kill command to the process. And you can call `alive?` to poll if the process is still alive.

## Example

If I wanted to kill firefox if it got more than 50% cpu or 600mb of memory.

    fx = PS(/Firefox.app/).first
    # only kill if taking up more than 50% cpu or 600mb of memory
    exit unless fx.pcpu > 50 || fx.mem > 600
    retries = 0
    fx.kill!
    while fx.alive?
      retries += 1
      if retries > 5
        # If sigint hasn't worked after .5 sec try SIGTERM
        fx.kill!("TERM")
      end
      sleep 0.1
    end