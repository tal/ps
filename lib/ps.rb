require "ps/version"

module PS
  extend self

  ALL_FORMATS = `ps -L`.chomp.split(/[\s\n]/).freeze
  FORMAT_ALIASES = {
    'pcpu' => '%cpu',
    'pmem' => '%mem',
    'acflg' => 'acflag',
    'f' => 'flags',
    'group' => 'gid',
    'inblock' => 'inblk',
    'ni' => 'nice',
    'nsignals' => 'nsigs',
    'oublock' => 'oublk',
    'pending' => 'sig',
    'blocked' => 'sigmask',
    'stat'    => 'stage',
    'cputime' => 'time',
    'usrpri' => 'upr',
    'putime' => 'utime',
    'vsize' => 'vsz'
  }

  DEFAULT_FORMATTING = %w{pid ppid pgid rss vsz %mem %cpu ruser
    user uid gid lstart state command}

  def all opts={}
    opts ||= {}
    opts[:flag] ||= %w{A}
    opts[:format] ||= DEFAULT_FORMATTING

    c = Command.new(opts)
    c.to_processes
  end

  def pid *pids
    opts = pids.pop if pids.last.is_a?(Hash) || pids.last.nil?
    opts ||= {}
    opts[:flag] ||= %w{}
    opts[:pid] = pids
    opts[:format] ||= DEFAULT_FORMATTING

    c = Command.new(opts)
    c.to_processes
  end

  def from_lsof match, args={}
    lines = `lsof -i #{match} -sTCP:LISTEN`.chomp.split("\n")
    lines.shift # remove header

    pids = lines.collect do |line|
      if m = line.match(/\s*\w+\s+(\d+)/)
        m[1].to_i
      end
    end.compact

    pids << args
    pid(*pids)
  end
end

require 'ps/command'
require 'ps/process'
require 'ps/process_list'
require 'ps/process_list_printer'

def PS *args
  case args[0]
  when /\:\d+$/
    PS.from_lsof(*args)
  when Regexp
    opts = args[1] || {}
    procs = PS.all(opts)
    procs = procs.select {|proc| proc.command =~ args[0]}
    procs = procs.select {|proc| proc.pid != Process.pid} unless opts[:include_self]
    procs
  when Integer
    if args[1].is_a?(Integer)
      PS.pid(*args)
    else
      PS.pid(*args).first
    end
  when Array
    pids = args[0]
    pids << args[1] || {}
    PS.pid(*pids)
  when Hash
    PS.all(*args)
  end
end
