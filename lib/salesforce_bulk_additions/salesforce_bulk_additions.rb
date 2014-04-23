module SalesforceBulk

	class Api

    def query_to_file(sobject, query, path)
      self.do_operation_to_file('query', sobject, query, nil, path)
    end

    def do_operation_to_file(operation, sobject, records, external_field, wait=false, path)
      job = SalesforceBulk::Job.new(operation, sobject, records, external_field, @connection)

      # TODO: put this in one function
      job_id = job.create_job()
      if(operation == "query")
        batch_id = job.add_query()
      else
        batch_id = job.add_batch()
      end
      job.close_job()

      if wait or operation == 'query'
        while true
          state = job.check_batch_status()
          if state != "Queued" && state != "InProgress"
            break
          end
          sleep(2) # wait x seconds and check again
        end
        
        if state == 'Completed'
          job.get_batch_result_to_file(path)
          job
        else
          job.result.message = "There is an error in your job. The response returned a state of #{state}. Please check your query/parameters and try again."
          job.result.success = false
          return job

        end
      else
        return job
      end

    end

	end

	class Connection
    
    def get_request_to_file(host, path, headers, output_file_path)
      host = host || @@INSTANCE_HOST
      path = "#{@@PATH_PREFIX}#{path}"

      if host != @@LOGIN_HOST # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
      end

      request = Net::HTTP::Get.new(path, headers)

			https(host).request(request) do |response|
				open output_file_path, 'w' do |io|
			  	response.read_body do |chunk|
			    	io.write chunk
			    end
			  end
			end

    end

  end

  class Job
  
    def get_batch_result_to_file(output_file_path)
      path = "job/#{@@job_id}/batch/#{@@batch_id}/result"
      headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]

      response = @@connection.get_request(nil, path, headers)

      if(@@operation == "query") # The query op requires us to do another request to get the results
        response_parsed = XmlSimple.xml_in(response)
        result_id = response_parsed["result"][0]

        path = "job/#{@@job_id}/batch/#{@@batch_id}/result/#{result_id}"
        headers = Hash.new
        headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]
        
        response = @@connection.get_request_to_file(nil, path, headers, output_file_path)

      end

      output_file_path
    end


  end

end