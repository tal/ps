require 'spec_helper'

describe PS::Command do

  it 'should remove header from format' do
   c = PS::Command.new
   c.formats << '%cpu'
   c.formats << '%mem'
   c.formats << 'command'
   c.to_s.should include('-o %cpu=,%mem=')
   c.to_s.should include('-o %cpu=,%mem=')
  end
end