require 'ansi/core'
require 'ansi/terminal'
require 'ansi/string'

module PS
  class ProcessList
    class Printer

      def initialize pl, headers=nil
        @headers = headers || %w{# pid ppid user pcpu mem command}
        @process_list = pl
      end

      def data
        data = []

        data << header_cells = @headers.collect do |header|
          {:val => header, :header => header}
        end

        @process_list.to_a.each_with_index do |proc,i|
          data << @headers.collect do |header|
            val = header == '#' ? i : proc.send(header)
            
            cell = {:val => val, :header => header}

            case header
            when 'pid'
              cell[:format] = [:blue]
            when '#'
              cell[:format] = [:yellow]
              cell[:align] = :right
            when 'user','ruser'
              cell[:align] = :center
            when 'mem'
              cell[:val] = val.round.to_s + 'mb'
              cell[:align] = :right
            when 'pcpu', 'pmem'
              cell[:align] = :right
              cell[:format] = case cell[:val]
              when 0.0...25.0
                []
              when 25.0..75.0
                [:red]
              else
                [:white,:on_red]
              end
              
              cell[:val] = (cell[:val]).to_i.to_s+'%'
            end

            cell
          end
        end

        data
      end

      def to_s
        printgrid(data)
      end

      private

      def printgrid(table)
        strs = []
        strings = table.map do |row|
          row.map { |cell| cell[:val].to_s }
        end

        column_widths = []
        strings.each do |row|
          row.each_with_index do |cell,i|
            column_widths[i] = [column_widths[i] || 0, cell.length].max
          end
        end

        row_separator = column_widths.map { |width| "-" * (width+2) }.join("+")[0...ANSI::Terminal.terminal_width]

        # strs << row_separator
        table.each_with_index do |row,ri|
          diff = 0
          justified_row = row.enum_for(:map).with_index do |cell,ci|
            val = cell[:val].to_s

            str = " "

            padded_val = case cell[:align]
            when :right
              val.rjust(column_widths[ci])
            when :center
              val.center(column_widths[ci])
            else
              val.ljust(column_widths[ci])
            end

            # padded_val.sub!(val,val.ansi(*cell[:format])) if cell[:format] && !cell[:format].empty?
            if cell[:format] && !cell[:format].empty?
              orig_len = padded_val.length
              padded_val.ansi!(*cell[:format])
              diff += padded_val.length - orig_len
            end

            str << padded_val

            str << " "
            str
          end
          strs << justified_row.join("|")[0...ANSI::Terminal.terminal_width+diff]
          strs << row_separator if ri == 0
        end

        strs.join("\n")
      end

    end
  end
end
