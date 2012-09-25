module GroupDocs
  class Signature::Envelope < Api::Entity

    require 'groupdocs/signature/envelope/log'

    include Signature::DocumentMethods
    include Signature::FieldMethods
    include Signature::RecipientMethods
    include Signature::TemplateFields

    #
    # Returns a list of all envelopes.
    #
    # @param [Hash] options Hash of options
    # @option options [Integer] :page Page to start with
    # @option options [Integer] :records How many items to list
    # @option options [Integer] :statusId Filter by status identifier
    # @option options [String] :recipient Filter by recipient email
    # @option options [String] :date Filter by date
    # @option options [String] :name Filter by name
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature::Envelope>]
    #
    def self.all!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/{{client_id}}/envelopes'
      end
      api.add_params(options)
      json = api.execute!

      json[:envelopes].map do |envelope|
        new(envelope)
      end
    end

    #
    # Returns a list of all envelopes where user is recipient.
    #
    # @param [Hash] options Hash of options
    # @option options [Integer] :page Page to start with
    # @option options [Integer] :records How many items to list
    # @option options [Integer] :statusId Filter by status identifier
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature::Envelope>]
    #
    def self.for_me!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/{{client_id}}/envelopes/recipient'
      end
      api.add_params(options)
      json = api.execute!

      json[:envelopes].map do |envelope|
        new(envelope)
      end
    end

    #
    # Returns an envelope by its identifier.
    #
    # @param [String] id
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Signature::Envelope]
    #
    def self.get!(id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/envelopes/#{id}"
      end.execute!

      new(json[:envelope])
    end

    #
    # Returns a list of resources of envelopes.
    #
    # @example
    #   resources = GroupDocs::Envelope.resources!
    #   resources[:documents]
    #   #=> [#<GroupDocs::Document>]
    #   resources[:recipients]
    #   #=> [#<GroupDocs::Signature::Recipient>]
    #   resources[:dates]
    #   #=> ["2012-09-25T00:00:00.0000000"]
    #
    # @param [Hash] options Hash of options
    # @option options [Array<Integer>] :status_ids List of status identifiers to filter
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Hash]
    #
    def self.resources!(options = {}, access = {})
      ids = options.delete(:status_ids)
      options[:statusIds] = ids.join(?,) if ids

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/envelopes/resources"
      end
      api.add_params(options)
      json = api.execute!

      resources = {}
      json.each do |key, value|
        resources[key] = case key
                         when :documents
                           value.map { |doc| Document.new(file: Storage::File.new(doc)) }
                         when :recipients
                           value.map { |recipient| Signature::Recipient.new(recipient) }
                         else
                           value
                         end
      end

      resources
    end

    # @attr [String] creationDateTime
    attr_accessor :creationDateTime
    # @attr [Symbol] status
    attr_accessor :status
    # @attr [String] statusDateTime
    attr_accessor :statusDateTime
    # @attr [Integer] envelopeExpireTime
    attr_accessor :envelopeExpireTime

    # Human-readable accessors
    alias_method :creation_date_time,    :creationDateTime
    alias_method :creation_date_time=,   :creationDateTime=
    alias_method :status_date_time,      :statusDateTime
    alias_method :status_date_time=,     :statusDateTime=
    alias_method :envelope_expire_time,  :envelopeExpireTime
    alias_method :envelope_expire_time=, :envelopeExpireTime=

    #
    # Adds recipient to envelope.
    #
    # @example
    #   roles = GroupDocs::Signature::Role.get!
    #   envelope = GroupDocs::Signature::Envelope.get!("g94h5g84hj9g4gf23i40j")
    #   recipient = GroupDocs::Signature::Recipient.new
    #   recipient.email = 'john@smith.com'
    #   recipient.first_name = 'John'
    #   recipient.last_name = 'Smith'
    #   recipient.role_id = roles.detect { |role| role.name == "Signer" }.id
    #   envelope.add_recipient! recipient
    #
    # @param [GroupDocs::Signature::Recipient] recipient
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if recipient is not GroupDocs::Signature::Recipient
    #
    def add_recipient!(recipient, access = {})
      recipient.is_a?(GroupDocs::Signature::Recipient) or raise ArgumentError,
        "Recipient should be GroupDocs::Signature::Recipient object, received: #{recipient.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/signature/{{client_id}}/envelopes/#{id}/recipient"
      end
      api.add_params(email:     recipient.email,
                     firstname: recipient.first_name,
                     lastname:  recipient.last_name,
                     role:      recipient.role_id,
                     order:     recipient.order)
      api.execute!
    end

    #
    # Modify recipient of envelope.
    #
    # @example
    #   envelope = GroupDocs::Signature::Envelope.get!("g94h5g84hj9g4gf23i40j")
    #   recipient = envelope.recipients!.first
    #   recipient.first_name = 'Johnny'
    #   envelope.modify_recipient! recipient
    #
    # @param [GroupDocs::Signature::Recipient] recipient
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if recipient is not GroupDocs::Signature::Recipient
    #
    def modify_recipient!(recipient, access = {})
      recipient.is_a?(GroupDocs::Signature::Recipient) or raise ArgumentError,
        "Recipient should be GroupDocs::Signature::Recipient object, received: #{recipient.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/envelopes/#{id}/recipient/#{recipient.id}"
      end
      api.add_params(email:     recipient.email,
                     firstname: recipient.first_name,
                     lastname:  recipient.last_name,
                     role:      recipient.role_id,
                     order:     recipient.order)
      api.execute!
    end

    #
    # Returns a list of audit logs.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature::Envelope::Log>]
    #
    def logs!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/envelopes/#{id}/logs"
      end.execute!

      json[:logs].map do |log|
        Log.new(log)
      end
    end



  end # Signature::Envelope
end # GroupDocs
