require "ps/version"

module PS
  extend self

  ALL_OPTS = `ps -L`.chomp.split(/[\s\n]/).freeze
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

  def default_formatting
    @default_formatting ||= ALL_OPTS
  end
  attr_writer :default_formatting

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
    opts = pids.pop if pids.last.is_a?(Hash)
    opts ||= {}
    opts[:flag] ||= %w{A}
    opts[:pid] = pids
    opts[:format] ||= DEFAULT_FORMATTING

    c = Command.new(opts)
    c.to_processes
  end
end

require 'ps/command'
require 'ps/process'
require 'ps/process_list'

def PS *args
  case args[0]
  when Regexp
    procs = PS.all(args[1])
    procs.select {|proc| proc.command =~ args[0]}
  when Integer
    PS.pid(args[0],args[1]).first
  when Hash
    PS.all(args[0])
  end
end
