module SplunkMan
  class Search 

    def initialize(splunk_server, user, password)
      @splunk_server = splunk_server
      @user = user
      @password = password
    end

    def search(search_query)
      @splunk_search = search_query 
      search_id = initiate_splunk_search @splunk_search
      wait_for_splunk_search(search_id)
      get_splunk_search_result search_id
    end

    private

    def initiate_splunk_search(splunk_search)
      filter_command = "egrep -o '<sid>.*</sid>' | sed -e 's/<sid>//;s/<\\/sid>//"
      uri = URI("#{@splunk_server}/search/jobs")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(@user, @password)
      request.form_data = { 'search' => splunk_search }

      response = http.request(request)
      search_id = nil
      if match = response.body.match(%r{<sid>([0-9\.]+)</sid>})
        search_id = match[1]
      end
      search_id
    end

    def wait_for_splunk_search(search_id)
      puts "waiting for result for search id #{search_id}"

      done = ''
      while done.empty? do
        filter_command = "grep -e isDone..1"
        puts "curl -k -s -u #{@user}:#{@password} #{@splunk_server}/search/jobs/#{search_id} | #{filter_command}"
        done=`curl -k -s -u #{@user}:#{@password} #{@splunk_server}/search/jobs/#{search_id} | #{filter_command}` 
        print "."
      end
    end

    def get_splunk_search_result(search_id)
      splunk_search_result = "curl -k -s -u #{@user}:#{@password} #{@splunk_server}/search/jobs/#{search_id}/results --get -d output_mode=json"
      `#{splunk_search_result}`
    end
  end
end

