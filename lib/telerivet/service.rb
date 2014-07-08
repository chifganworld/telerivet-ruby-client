module Telerivet

#
# Represents an automated service on Telerivet, for example a poll, auto-reply, webhook
# service, etc.
# 
# A service, generally, defines some automated behavior that can be
# invoked/triggered in a particular context, and may be invoked either manually or when a
# particular event occurs.
# 
# Most commonly, services work in the context of a particular message, when
# the message is originally received by Telerivet.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the service
#       * Read-only
#   
#   - name
#       * Name of the service
#       * Updatable via API
#   
#   - active (bool)
#       * Whether the service is active or inactive. Inactive services are not automatically
#           triggered and cannot be invoked via the API.
#       * Updatable via API
#   
#   - priority (int)
#       * A number that determines the order that services are triggered when a particular
#           event occurs (smaller numbers are triggered first). Any service can determine whether
#           or not execution "falls-through" to subsequent services (with larger priority values)
#           by setting the return_value variable within Telerivet's Rules Engine.
#       * Updatable via API
#   
#   - contexts (Hash)
#       * A key/value map where the keys are the names of contexts supported by this service
#           (e.g. message, contact), and the values are themselves key/value maps where the keys
#           are event names and the values are all true. (This structure makes it easy to test
#           whether a service can be invoked for a particular context and event.)
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this service
#       * Updatable via API
#   
#   - project_id
#       * ID of the project this service belongs to
#       * Read-only
#   
#   - label_id
#       * ID of the label containing messages sent or received by this service (currently only
#           used for polls)
#       * Read-only
#   
#   - response_table_id
#       * ID of the data table where responses to this service will be stored (currently only
#           used for polls)
#       * Read-only
#   
#   - sample_group_id
#       * ID of the group containing contacts that have been invited to interact with this
#           service (currently only used for polls)
#       * Read-only
#   
#   - respondent_group_id
#       * ID of the group containing contacts that have completed an interaction with this
#           service (currently only used for polls)
#       * Read-only
#
class Service < Entity

    #
    # Manually invoke this service in a particular context.
    # 
    # For example, to send a poll to a particular contact (or resend the
    # current question), you can invoke the poll service with context=contact, and contact_id as
    # the ID of the contact to send the poll to.
    # 
    # Or, to manually apply a service for an incoming message, you can
    # invoke the service with context=message, event=incoming\_message, and message_id as the ID
    # of the incoming message. (This is normally not necessary, but could be used if you want to
    # override Telerivet's standard priority-ordering of services.)
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - context
    #         * The name of the context in which this service is invoked
    #         * Allowed values: message, contact, project, receipt
    #         * Required
    #     
    #     - event
    #         * The name of the event that is triggered (must be supported by this service)
    #         * Default: default
    #     
    #     - message_id
    #         * The ID of the message this service is triggered for
    #         * Required if context is 'message'
    #     
    #     - contact_id
    #         * The ID of the contact this service is triggered for
    #         * Required if context is 'contact'
    #   
    # Returns:
    #     object
    #
    def invoke(options)        
        invoke_result = @api.do_request('POST', get_base_api_path() + '/invoke', options)
        
        if invoke_result.has_key?('sent_messages')
            require_relative 'message'
        
            sent_messages = []
            
            invoke_result['sent_messages'].each { |sent_message_data|
                sent_messages.push(Message.new(@api, sent_message_data))
            }
            
            invoke_result['sent_messages'] = sent_messages
        end
            
        return invoke_result
    end
    
    #
    # Gets the current state for a particular contact for this service.
    # 
    # If the contact doesn't already have a state, this method will return
    # a valid state object with id=null. However this object would not be returned by
    # queryContactStates() unless it is saved with a non-null state id.
    # 
    # Arguments:
    #   - contact (Telerivet::Contact)
    #       * The contact whose state you want to retrieve.
    #       * Required
    #   
    # Returns:
    #     Telerivet::ContactServiceState
    #
    def get_contact_state(contact)
        require_relative 'contactservicestate'
        ContactServiceState.new(@api, @api.do_request('GET', get_base_api_path() + '/states/' + contact.id))
    end

    #
    # Initializes or updates the current state for a particular contact for the given service. If
    # the state id is null, the contact's state will be reset.
    # 
    # Arguments:
    #   - contact (Telerivet::Contact)
    #       * The contact whose state you want to update.
    #       * Required
    #   
    #   - options (Hash)
    #       * Required
    #     
    #     - id (string, max 63 characters)
    #         * Arbitrary string representing the contact's current state for this service, e.g.
    #             'q1', 'q2', etc.
    #         * Required
    #     
    #     - vars (Hash)
    #         * Custom variables stored for this contact's state
    #   
    # Returns:
    #     Telerivet::ContactServiceState
    #
    def set_contact_state(contact, options)
        require_relative 'contactservicestate'
        ContactServiceState.new(@api, @api.do_request('POST', get_base_api_path() + '/states/' + contact.id, options))
    end
    
    #
    # Resets the current state for a particular contact for the given service.
    # 
    # Arguments:
    #   - contact (Telerivet::Contact)
    #       * The contact whose state you want to reset.
    #       * Required
    #   
    # Returns:
    #     Telerivet::ContactServiceState
    #
    def reset_contact_state(contact)
        require_relative 'contactservicestate'
        ContactServiceState.new(@api, @api.do_request('DELETE', get_base_api_path() + '/states/' + contact.id))
    end

    #
    # Query the current states of contacts for this service.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - id
    #         * Filter states by id
    #         * Allowed modifiers: id[ne], id[prefix], id[not_prefix], id[gte], id[gt], id[lt],
    #             id[lte]
    #     
    #     - vars (Hash)
    #         * Filter states by value of a custom variable (e.g. vars[email], vars[foo], etc.)
    #         * Allowed modifiers: vars[foo][exists], vars[foo][ne], vars[foo][prefix],
    #             vars[foo][not_prefix], vars[foo][gte], vars[foo][gt], vars[foo][lt], vars[foo][lte],
    #             vars[foo][min], vars[foo][max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 200)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::ContactServiceState)
    #
    def query_contact_states(options = nil)
        require_relative 'contactservicestate'
        @api.cursor(ContactServiceState, get_base_api_path() + "/states", options)
    end

    #
    # Saves any fields or custom variables that have changed for this service.
    #
    def save()
        super
    end

    def id
        get('id')
    end

    def name
        get('name')
    end

    def name=(value)
        set('name', value)
    end

    def active
        get('active')
    end

    def active=(value)
        set('active', value)
    end

    def priority
        get('priority')
    end

    def priority=(value)
        set('priority', value)
    end

    def contexts
        get('contexts')
    end

    def project_id
        get('project_id')
    end

    def label_id
        get('label_id')
    end

    def response_table_id
        get('response_table_id')
    end

    def sample_group_id
        get('sample_group_id')
    end

    def respondent_group_id
        get('respondent_group_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/services/#{get('id')}"
    end
 
end

end
