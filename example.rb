$:.unshift File.dirname(__FILE__) + '/lib'

require 'dotenv'
Dotenv.load

require 'salesforce_bulk_additions'
require 'benchmark'
require 'time'
require 'chronic_duration'
require 'pry-debugger'
require 'fileutils'
require 'pp'

include FileUtils


tmp_dir_name = 'tmp'
mkdir_p(tmp_dir_name) if !File.directory?(tmp_dir_name)

output_file_path = "tmp/LoginHistory.csv"
time = Benchmark.realtime do
  # connect to production example (no 3rd param)
  #sfb = SalesforceBulk::Api.new("username", "password")
  sfb = SalesforceBulk::Api.new(ENV['USERNAME'], ENV['PASSWORD'], ENV['SANDBOX'] == 'true')
  res = sfb.query_to_file("LoginHistory", %{select ApiType, ApiVersion, Application, Browser, ClientVersion, Id, LoginTime, LoginType, LoginUrl, Platform, SourceIp, Status, UserId from LoginHistory limit 100}, output_file_path)
  pp res
end
record_count = (%x{cat '#{output_file_path}' | wc -l}.strip.to_i) - 1
puts "#{record_count} records - elapsed time: #{ChronicDuration.output(time)}"


# converts csv file with quoted values to unquoted values
# used to prepare file for upload to hadoop / hive metastore
def strip_csv_quotes(src_path, dest_path)

  require 'csv'
  open('LoginHistory-comma-delim.csv', 'w') do |f|
    first_line = true
    CSV.foreach('LoginHistory.csv') do |row|
      if first_line
        first_line = false
      else
        f.puts(  row.join(',') )
      end
      
    end
  end

end

#strip_csv_quotes('tmp/LoginHistory.csv', 'tmp/LoginHistory-comma-delim.csv')
