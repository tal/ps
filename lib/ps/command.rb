module PS
  class Command
    ARR_ARGS = {
      :format => '-o ',
      :gid => '-G ',
      :group => '-g ',
      :uid => '-u ',
      :pid => '-p ',
      :tty => '-t ',
      :user => '-U ',
      :flag => '-'
    }

    attr_reader *ARR_ARGS.keys.collect {|key| key.to_s+'s'}
    FLAG_LIST = 'AaCcEefhjlMmrSTvwXx'.split('').freeze

    def initialize opts={}
      ARR_ARGS.keys.each do |arg|
        arr = opts[arg] || []
        instance_variable_set "@#{arg}s", arr
      end
    end

    def to_s
      cmd = []

      parse_formats!

      ARR_ARGS.each do |var,trigger|
        sep = var == :flags ? nil : ','
        vals = instance_variable_get("@#{var}s").uniq
        cmd << trigger+vals.join(sep) unless vals.empty?
      end

      "ps "<<cmd.join(' ')
    end

    def run!
      `#{to_s}`.chomp
    end

    def regex
      r = @last_ran_formats.inject("") do |reg,fmt|
        reg << '\s*' << case fmt
        when 'command='
          '(.+)$'
        when 'lstart='
          '(\w{3}\s\w{3}\s[\s\d]{2}\s[\d\:]{8}\s\d{4})'
        else
          '([\w\,_\-\.]+)'
        end
      end

      Regexp.new(r)
    end

    def to_hashes
      reg = nil
      run!.split("\n").collect do |line|
        reg ||= regex
        m = line.match(reg)
        hsh = {}
        @last_ran_formats.each_with_index do |val,i|
          hsh[val.sub('=','')] = m[i+1].rstrip
        end

        hsh
      end
    end

    def to_processes
      to_hashes.inject(ProcessList.new) {|plist,hsh| plist << Process.new(hsh)}
    end

    private

    def parse_formats!
      @formats.each do |format|
        format = format.sub('=','')
        unless DEFAULT_FORMATTING.include?(format)
          warn("Untested formatting option: #{format}")
        end
      end

      @formats = @formats.collect do |format|
        format = FORMAT_ALIASES[format.sub('=','')] || format
        format.sub(/(=)?$/,'=')
      end.uniq

      # ensure command is always at the end of the formats array
      if @formats.delete('command=')
        @formats.push('command=')
      end

      # prevent race conditions
      @last_ran_formats = @formats
    end

  end
end
