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
      find_all do |proc|
        proc.__send__(val) >= amnt
      end
    end

    def to_a
      @target
    end

    def print headers=nil, to=nil
      to ||= STDOUT
      printer = Printer.new(self,headers)
      to.send :puts, printer.to_s
    end

    # Print out all the processes and accept user input to return
    # the process objects selected.
    def choose question=nil
      if empty?
        puts "No processes found."
        return self
      end
      question ||= 'Select process(s):'
      self.print
      puts "\n#{question}"
      proc_ids = STDIN.gets.chomp
      proc_ids = '*' if proc_ids.empty?
      proc_ids = proc_ids.split(/[,\s]/)

      if proc_ids.include?('*')
        proc_ids = (0..self.size).to_a
      else
        proc_ids = proc_ids.collect do |proc_id|
          case proc_id
          when /^\d+$/
            proc_id.to_i
          when /^(\d+)(\.{2,3})(\d*)$/
            if $3.empty?
              ($1.to_i..self.size).to_a
            elsif $2.size === 3
              ($1.to_i...$3.to_i).to_a
            else
              ($1.to_i..$3.to_i).to_a
            end
          when /^(\d+)\-(\d+)$/
            ($1.to_i..$2.to_i).to_a
          end
        end.flatten.uniq
      end

      procs = self.class.new

      proc_ids.each do |proc_id|
        proc = @target[proc_id.to_i]

        procs << proc
      end

      procs
    end

    # Ugh shoot me for using method missing, couldn't get
    # it to work any other way.
    def method_missing(*args, &blk)
      new_target = @target.send(*args, &blk)

      new_target.class == @target.class ? self.class.new(new_target) : new_target
    end
  end
end
