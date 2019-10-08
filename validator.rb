#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'wasabi'
require 'colorize'
require './wsdl_validator.rb'

xml_file = ARGV[0]

raise ArgumentError.new("Message file is missing") if xml_file.nil?

schema_file = 'files/customer-info-update.wsdl'

document = Nokogiri::XML(File.open(xml_file))

wsdl = WsdlValidator.new(schema_file)
errors = wsdl.validate(document)

if errors.size == 0
  puts "[Soap Validator] " + "PASS: No errors".green
else
  errors.each do |error|
    STDERR.puts "[Soap Validator] " + "FAIL:".red
    raise error.message.red
  end  
end