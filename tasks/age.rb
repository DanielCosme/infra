# frozen_string_literal: true

# Encodde secrets
# Decode secrets
require_relative '../config/inventory'

def encrypt
  files = `ls #{SECRETS_PATH}`
  files.split("\n").each do |file|
    full_path = "#{SECRETS_PATH}/#{file}"
    full_path_enc = "#{ENC_SECRETS_PATH}/#{file}.age"
    puts "Encrypting: #{file} into #{full_path_enc}"
    res = `age \
      --encrypt \
      --output #{full_path_enc} \
      --identity #{ENV['AGE_KEY']} \
      #{full_path}`
    puts res if $?.exitstatus > 0
  end
end

def decrypt
  `mkdir -p #{SECRETS_PATH}`
  files = `ls #{ENC_SECRETS_PATH}`
  files.split("\n").each do |file|
    file_cut = File.basename(file, '.age')
    secrets_path = "#{SECRETS_PATH}/#{file_cut}"
    enc_secrets_path = "#{ENC_SECRETS_PATH}/#{file}"
    puts "Decrypting: #{file} into #{secrets_path}"
    res = `age \
          --decrypt \
          --identity #{ENV['AGE_KEY']} \
          #{enc_secrets_path} > #{secrets_path}`
    puts res if $?.exitstatus > 0
  end
end
