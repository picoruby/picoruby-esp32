require 'machine'
require "watchdog"
Watchdog.disable
STDIN = IO.new
STDOUT = IO.new

require 'littlefs'
require 'vfs'
flash = Littlefs.new(:flash, label: 'storage')
VFS.mount(flash, "/")

begin
  GC.start

  if File.exist?("/home/app.mrb")
    puts "Loading app.mrb"
    load "/home/app.mrb"
  elsif File.exist?("/home/app.rb")
    puts "Loading app.rb"
    load "/home/app.rb"
  end
rescue => e
  puts "#{e.message} (#{e.class})"
end
