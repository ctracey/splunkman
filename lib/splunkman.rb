require 'rubygems'
require 'json'

class SplunkMan

  def initialize(splunk_server, user, password, splunk_search)
    @splunk_search = splunk_search
    @splunk_server = splunk_server
    @user = user
    @password = password
  end

  def execute
    search_id = initiate_splunk_search @splunk_search
    wait_for_splunk_search(search_id)
    get_splunk_search_result search_id
  end

  private

  def initiate_splunk_search(splunk_search)
    filter_command = "egrep -o '<sid>.*</sid>' | sed -e 's/<sid>//;s/<\\/sid>//"
    splunk_search_request = "curl -k -s -u #{@user}:#{@password} #{@splunk_server}/search/jobs -d #{splunk_search} | #{filter_command} '"
    `#{splunk_search_request}`.chomp
  end

  def wait_for_splunk_search(search_id)
    puts "waiting for result for search id #{search_id}"

    done = ''
    while done.empty? do
      filter_command = "grep -e isDone..1"
      done=`curl -k -s -u #{@user}:#{@password} #{@splunk_server}/search/jobs/#{search_id} | #{filter_command}` 
      print "."
    end
  end

  def get_splunk_search_result(search_id)
    splunk_search_result = "curl -k -s -u #{@user}:#{@password} #{@splunk_server}/search/jobs/#{search_id}/results --get -d output_mode=json"
    JSON.parse(`#{splunk_search_result}`)
  end
end
