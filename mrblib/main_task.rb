require 'machine'
require "watchdog"
require 'env'
require 'yaml'
require "mbedtls"
require "base64"
require 'esp32'
Watchdog.disable
require "shell"
STDIN = IO.new
STDOUT = IO.new

def decrypt(decoded_password)
  cipher = MbedTLS::Cipher.new("AES-256-CBC")
  cipher.decrypt
  key_len = cipher.key_len
  iv_len = cipher.iv_len
  unique_id = Machine.unique_id
  len = unique_id.length
  cipher.key = (unique_id * ((key_len / len + 1) * len))[0, key_len].to_s
  cipher.iv = (unique_id * ((iv_len / len + 1) * len))[0, iv_len].to_s
  # Based on successful debug run: CBC mode has empty tag, so entire data is ciphertext
  ciphertext = decoded_password
  cipher.update(ciphertext) + cipher.finish
end

def parse_wifi_config
  wifi_config_path = ENV['WIFI_CONFIG_PATH'] || ENV_DEFAULT_WIFI_CONFIG_PATH

  unless File.file?(wifi_config_path)
    puts "File #{wifi_config_path} does not exist"
    return
  end

  config = File.open(wifi_config_path, "r") do |f|
    YAML.load(f.read.to_s)
  end

  begin
    ssid = config['wifi']['ssid']
    encoded_password = config['wifi']['encoded_password']
  rescue
    puts "Invalid configuration file"
    return
  end

  decoded_password = Base64.decode64(encoded_password)
  password = decrypt(decoded_password)

  return ssid, password
end

def setup_wifi
  ssid, password = parse_wifi_config
  return if ssid.nil? || password.nil?

  ESP32::WiFi.init
  5.times do |i|
    break if ESP32::WiFi.connect_timeout(ssid, password, ESP32::Auth::WPA2_AES_PSK, 10000)

    puts "Retrying WiFi connection..."
    Machine.delay_ms(1000)
  end
  print "WiFi "
  puts ESP32::WiFi.tcpip_link_status == ESP32::WiFi::LINK_UP ? "connected successfully" : "connection failed"
end

# Setup flash disk
begin
  STDIN.echo = false
  puts "Initializing FLASH disk as the root volume... "
  Shell.setup_root_volume(:flash, label: 'storage')
  Shell.setup_system_files
  puts "Available"
rescue => e
  puts "Not available"
  puts "#{e.message} (#{e.class})"
end

GC.start

begin
  setup_wifi

  if File.exist?("/home/app.mrb")
    puts "Loading app.mrb"
    load "/home/app.mrb"
  elsif File.exist?("/home/app.rb")
    puts "Loading app.rb"
    load "/home/app.rb"
  end

  GC.start

  $shell = Shell.new(clean: true)
  puts "Starting shell...\n\n"

  $shell.show_logo
  $shell.start
rescue => e
  puts "#{e.message} (#{e.class})"
end
