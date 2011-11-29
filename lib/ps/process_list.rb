module PS
  class ProcessList
    def initialize(target=nil)
      @target = target || []
    end

    def command regex
      grep(regex) {|proc| proc.command||proc.cmd}
    end

    def pids
      @target.collect {|proc| proc.pid}.compact
    end

    def over val, amnt
      select do |proc|
        proc.__send__(val) >= amnt
      end
    end

    # Ugh shoot me for using method missing, couldn't get
    # it to work any other way.
    def method_missing(name, *args, &blk)
      new_target = @target.send(name, *args, &blk)
       
      new_target.class == @target.class ? self.class.new(new_target) : new_target
    end
  end
end
