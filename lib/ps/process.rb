module PS
  class Process

    ALL_FORMATS.each do |opt|
      define_method opt do
        @data[opt]
      end
    end

    FORMAT_ALIASES.each do |al,orig|
      define_method al do
        @data[orig]
      end
    end

    def initialize data
      @data = {}

      data.each do |key,value|
        @data[key] = case value
        when /^\-?\d+$/
          value.to_i
        when /^\-?\d+\.\d+$/
          value.to_f
        else
          value.strip
        end
      end
    end

    def include? value
      @data.has_key?(value.to_s)
    end

    def has
      @data.keys
    end

    def mem
      rss/1024.0 if rss
    end

    def alive?
      return unless pid
      ::Process.getpgid(pid)
      true
    rescue Errno::ESRCH
      false
    end

    def display
      disp = []
      disp << pid
      disp << user
      disp << lstart
      disp << pcpu
      disp << pmem
      disp << mem
      disp << command
      disp.compact.join(' ')
    end

    def kill!(sig=nil)
      sig ||= 'INT'
      ::Process.kill(sig, pid) if pid
    end

  end
end
