require 'datomic/client/version'
require 'datomic/client/response'
require 'rest-client'
require 'set' # Remove when fixed upstream
require 'edn'

module Datomic
  class Client
    HANDLE_RESPONSE = lambda do |body, request, response|
      Response.new body, response, request
    end

    def initialize(url, storage = nil)
      @url = url
      @storage = storage
    end

    def create_database(dbname)
      RestClient.post root_url('data', @storage) + "/", {"db-name" => dbname},
        :content_type => 'application/x-www-form-urlencoded', &HANDLE_RESPONSE
    end

    # Options:
    # * :t - Specifies version/time of db. Defaults to latest version
    def database_info(dbname, options = {})
      version = options.fetch(:t, '-')
      get db_url(dbname, version) + "/", :Accept => 'application/edn'
    end

    # Data can be a ruby data structure or a string representing clojure data
    def transact(dbname, data)
      data = transmute_data(data)
      RestClient.post(db_url(dbname) + "/", {"tx-data" => data},
                      :Accept => 'application/edn', &HANDLE_RESPONSE)
    end

    # This endpoint hits both datoms and index-range APIs.
    # params take any param in addition to following options:
    #
    # Options:
    # * :t - Specifies version/time of db. Defaults to latest version
    def datoms(dbname, params = {})
      version = params.fetch(:t, '-')
      get db_url(dbname, version, "datoms"), :params => params,
        :Accept => 'application/edn'
    end

    # params take any param in addition to following options:
    #
    # Options:
    # * :t - Specifies version/time of db. Defaults to latest version
    def entity(dbname, id, params = {})
      version = params.fetch(:t, '-')
      get db_url(dbname, version, 'entity'), :params => params.merge(:e => id),
        :Accept => 'application/edn'
    end

    # Query can be a ruby data structure or a string representing clojure data
    def query(dbname, query, params = {})
      query = transmute_data(query)
      args = [{:"db/alias" => [@storage, dbname].join('/')}].to_edn
      get root_url("api/query"), :params => params.merge(:q => query, :args => args),
        :Accept => 'application/edn'
    end

    def monitor(dbname)
      get db_url(dbname, '-', 'events')
    end

    # Given block is called with Net::HTTPOK response from event
    def events(dbname, &block)
      # can't use RestClient.get b/c of :block_response
      RestClient::Request.execute(:method => :get,
        :url => root_url('events', @storage, dbname),
        :headers => {:accept => "text/event-stream"},
        :block_response => block, &HANDLE_RESPONSE)
    end

    private

    def get(*args)
      RestClient.get(*args, &HANDLE_RESPONSE)
    end

    def root_url(*parts)
      [@url].concat(parts).join('/')
    end

    def db_url(dbname, *parts)
      root_url 'data', @storage, dbname, *parts
    end

    def transmute_data(data)
      data.is_a?(String) ? data : data.to_edn
    end
  end
end
