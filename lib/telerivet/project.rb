
module Telerivet

#
# Represents a Telerivet project.
# 
# Provides methods for sending and scheduling messages, as well as
# accessing, creating and updating a variety of entities, including contacts, messages,
# scheduled messages, groups, labels, phones, services, and data tables.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the project
#       * Read-only
#   
#   - name
#       * Name of the project
#       * Updatable via API
#   
#   - timezone_id
#       * Default TZ database timezone ID; see
#           <http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
#       * Read-only
#   
#   - url_slug
#       * Unique string used as a component of the project's URL in the Telerivet web app
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this project
#       * Updatable via API
#   
#   - organization_id (string, max 34 characters)
#       * ID of the organization this project belongs to
#       * Read-only
#
class Project < Entity
    #
    # Sends one message (SMS, voice call, or USSD request).
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send
    #         * Allowed values: sms, ussd, call
    #         * Default: sms
    #     
    #     - content
    #         * Content of the message to send (if `message_type` is `call`, the text will be
    #             spoken during a text-to-speech call)
    #         * Required if sending SMS message
    #     
    #     - to_number (string)
    #         * Phone number to send the message to
    #         * Required if contact_id not set
    #     
    #     - contact_id
    #         * ID of the contact to send the message to
    #         * Required if to_number not set
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID for your project
    #     
    #     - service_id
    #         * Service that defines the call flow of the voice call (when `message_type` is
    #             `call`)
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #     
    #     - status_url
    #         * Webhook callback URL to be notified when message status changes
    #     
    #     - status_secret
    #         * POST parameter 'secret' passed to status_url
    #     
    #     - is_template (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content. [(See
    #             available variables)](#variables)
    #         * Default: false
    #     
    #     - label_ids (array)
    #         * List of IDs of labels to add to this message
    #     
    #     - vars (Hash)
    #         * Custom variables to store with the message
    #     
    #     - priority (int)
    #         * Priority of the message (currently only observed for Android phones). Telerivet
    #             will attempt to send messages with higher priority numbers first (for example, so
    #             you can prioritize an auto-reply ahead of a bulk message to a large group).
    #         * Default: 1
    #   
    # Returns:
    #     Telerivet::Message
    #
    def send_message(options)
        require_relative 'message'
        Message.new(@api, @api.do_request("POST", get_base_api_path() + "/messages/send", options))
    end

    #
    # Sends a text message (optionally with mail-merge templates) or voice call to a group or a
    # list of up to 500 phone numbers
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send
    #         * Allowed values: sms, call
    #         * Default: sms
    #     
    #     - content
    #         * Content of the message to send
    #         * Required if sending SMS message
    #     
    #     - group_id
    #         * ID of the group to send the message to
    #         * Required if to_numbers not set
    #     
    #     - to_numbers (array of strings)
    #         * List of up to 500 phone numbers to send the message to
    #         * Required if group_id not set
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID
    #     
    #     - title (string)
    #         * Title of the broadcast. If a title is not provided, a title will automatically be
    #             generated from the recipient group name or phone numbers.
    #     
    #     - service_id
    #         * Service that defines the call flow of the voice call (when `message_type` is
    #             `call`)
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #     
    #     - status_url
    #         * Webhook callback URL to be notified when message status changes
    #     
    #     - status_secret
    #         * POST parameter 'secret' passed to status_url
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to all messages sent (maximum 5)
    #     
    #     - exclude_contact_id
    #         * Optionally excludes one contact from receiving the message (only when group_id is
    #             set)
    #     
    #     - is_template (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content [(See
    #             available variables)](#variables)
    #         * Default: false
    #     
    #     - vars (Hash)
    #         * Custom variables to set for each message
    #   
    # Returns:
    #     Telerivet::Broadcast
    #
    def send_broadcast(options)
        require_relative 'broadcast'
        Broadcast.new(@api, @api.do_request("POST", get_base_api_path() + "/send_broadcast", options))
    end

    #
    # Sends up to 100 different messages in a single API request. This method is significantly
    # faster than sending a separate API request for each message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - messages (array)
    #         * Array of up to 100 objects with `content` and `to_number` properties
    #         * Required
    #     
    #     - message_type
    #         * Type of message to send
    #         * Allowed values: sms
    #         * Default: sms
    #     
    #     - route_id
    #         * ID of the phone or route to send the messages from
    #         * Default: default sender route ID
    #     
    #     - broadcast_id (string)
    #         * ID of an existing broadcast to associate the messages with
    #     
    #     - broadcast_title (string)
    #         * Title of broadcast to create (when `broadcast_id` is not provided).
    #             When sending more than 100 messages over multiple API
    #             requests, you can associate all messages with the same broadcast by providing a
    #             `broadcast_title` parameter in the first
    #             API request, then retrieving the `broadcast_id` property
    #             from the API response, and passing it as the `broadcast_id` parameter in subsequent
    #             API requests.
    #     
    #     - status_url
    #         * Webhook callback URL to be notified when message status changes
    #     
    #     - status_secret
    #         * POST parameter 'secret' passed to status_url
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to each message (maximum 5)
    #     
    #     - is_template (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content [(See
    #             available variables)](#variables)
    #         * Default: false
    #   
    # Returns:
    #     (associative array)
    #       - messages (array)
    #           * List of objects representing each newly created message, with the same length
    #               and order as provided in the `messages` parameter in the API request.
    #               Each object has the `id` and `status` properties,
    #               and may have the property `error_message`.
    #               (Other properties of the Message object are
    #               omitted in order to reduce the amount of redundant data sent in each API
    #               response.)
    #       
    #       - broadcast_id
    #           * ID of broadcast that these messages are associated with, if `broadcast_id` or
    #               `broadcast_title` parameter is provided in the API request.
    #
    def send_multi(options)
        data = @api.do_request("POST", get_base_api_path() + "/send_multi", options)
        return data
    end

    #
    # (Deprecated) Send a message a to group or a list of phone numbers.
    # This method is only needed to maintain backward compatibility with
    # code developed using previous versions of the client library.
    # Use `sendBroadcast` or `sendMulti` instead.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #     
    #     - content
    #         * Required
    #     
    #     - group_id
    #     
    #     - to_numbers
    #   
    # Returns:
    #     (associative array)
    #       - count_queued (int)
    #           * Number of messages queued to send
    #       
    #       - broadcast_id
    #           * ID of broadcast created for this message batch.
    #
    def send_messages(options)
        data = @api.do_request("POST", get_base_api_path() + "/messages/send_batch", options)
        return data
    end

    #
    # Schedules a message to a group or single contact. Note that Telerivet only sends scheduled
    # messages approximately once every 15 seconds, so it is not possible to control the exact
    # second at which a scheduled message is sent.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send
    #         * Allowed values: sms, ussd, call
    #         * Default: sms
    #     
    #     - content
    #         * Content of the message to schedule
    #         * Required if sending SMS message
    #     
    #     - group_id
    #         * ID of the group to send the message to
    #         * Required if to_number not set
    #     
    #     - to_number (string)
    #         * Phone number to send the message to
    #         * Required if group_id not set
    #     
    #     - start_time (UNIX timestamp)
    #         * The time that the message will be sent (or first sent for recurring messages)
    #         * Required if start_time_offset not set
    #     
    #     - start_time_offset (int)
    #         * Number of seconds from now until the message is sent
    #         * Required if start_time not set
    #     
    #     - rrule
    #         * A recurrence rule describing the how the schedule repeats, e.g. 'FREQ=MONTHLY' or
    #             'FREQ=WEEKLY;INTERVAL=2'; see <https://tools.ietf.org/html/rfc2445#section-4.3.10>.
    #             (UNTIL is ignored; use end_time parameter instead).
    #         * Default: COUNT=1 (one-time scheduled message, does not repeat)
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID
    #     
    #     - service_id
    #         * Service that defines the call flow of the voice call (when `message_type` is
    #             `call`)
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #     
    #     - is_template (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content
    #         * Default: false
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to the sent messages (maximum 5)
    #     
    #     - timezone_id
    #         * TZ database timezone ID; see
    #             <http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
    #         * Default: project default timezone
    #     
    #     - end_time (UNIX timestamp)
    #         * Time after which a recurring message will stop (not applicable to non-recurring
    #             scheduled messages)
    #     
    #     - end_time_offset (int)
    #         * Number of seconds from now until the recurring message will stop
    #   
    # Returns:
    #     Telerivet::ScheduledMessage
    #
    def schedule_message(options)
        require_relative 'scheduledmessage'
        ScheduledMessage.new(@api, @api.do_request("POST", get_base_api_path() + "/scheduled", options))
    end

    #
    # Add an incoming message to Telerivet. Acts the same as if the message was received by a
    # phone. Also triggers any automated services that apply to the message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - content
    #         * Content of the incoming message
    #         * Required unless `message_type` is `call`
    #     
    #     - message_type
    #         * Type of message
    #         * Allowed values: sms, call
    #         * Default: sms
    #     
    #     - from_number
    #         * Phone number that sent the incoming message
    #         * Required
    #     
    #     - phone_id
    #         * ID of the phone (basic route) that received the message
    #         * Required
    #     
    #     - to_number
    #         * Phone number that the incoming message was sent to
    #         * Default: phone number of the phone that received the message
    #     
    #     - simulated (bool)
    #         * If true, Telerivet will not send automated replies to actual phones
    #     
    #     - starred (bool)
    #         * True if this message should be starred
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to this message (maximum 5)
    #     
    #     - vars (Hash)
    #         * Custom variables to set for this message
    #   
    # Returns:
    #     Telerivet::Message
    #
    def receive_message(options)
        require_relative 'message'
        Message.new(@api, @api.do_request("POST", get_base_api_path() + "/messages/receive", options))
    end

    #
    # Retrieves OR creates and possibly updates a contact by name or phone number.
    # 
    # If a phone number is provided, by default, Telerivet will search for
    # an existing contact with that phone number (including suffix matches to allow finding
    # contacts with phone numbers in a different format). If a phone number is not provided but a
    # name is provided, Telerivet will search for a contact with that exact name (case
    # insensitive). This behavior can be modified by setting the `lookup_key` parameter to look up
    # a contact by another field, including a custom variable.
    # 
    # If no existing contact is found, a new contact will be created.
    # 
    # Then that contact will be updated with any parameters provided
    # (`name`, `phone_number`, `vars`, `default_route_id`, `send_blocked`, `add_group_ids`,
    # `remove_group_ids`).
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Name of the contact
    #     
    #     - phone_number
    #         * Phone number of the contact
    #     
    #     - lookup_key
    #         * The field used to search for a matching contact, or 'none' to always create a new
    #             contact. To search by a custom variable, precede the variable name with 'vars.'.
    #         * Allowed values: phone_number, name, id, vars.variable_name, none
    #         * Default: phone_number
    #     
    #     - send_blocked (bool)
    #         * True if Telerivet is blocked from sending messages to this contact
    #     
    #     - default_route_id
    #         * ID of the route to use by default to send messages to this contact
    #     
    #     - add_group_ids (array)
    #         * ID of one or more groups to add this contact as a member (max 20)
    #     
    #     - id
    #         * ID of an existing contact (only used if `lookup_key` is 'id')
    #     
    #     - remove_group_ids (array)
    #         * ID of one or more groups to remove this contact as a member (max 20)
    #     
    #     - vars (Hash)
    #         * Custom variables and values to update on the contact
    #   
    # Returns:
    #     Telerivet::Contact
    #
    def get_or_create_contact(options = nil)
        require_relative 'contact'
        Contact.new(@api, @api.do_request("POST", get_base_api_path() + "/contacts", options))
    end

    #
    # Creates and/or updates up to 200 contacts in a single API call. When creating or updating a
    # large number of contacts, this method is significantly faster than sending a separate API
    # request for each contact.
    # 
    # By default, if the phone number for any contact matches an existing
    # contact, the existing contact will be updated with any information provided. This behavior
    # can be modified by setting the `lookup_key` parameter to look up contacts by another field,
    # including a custom variable.
    # 
    # If any contact was not found matching the provided `lookup_key`, a
    # new contact will be created.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - contacts (array)
    #         * Array of up to 200 objects which may contain the properties `name` (string),
    #             `phone_number` (string), `vars` (object), and `send_blocked` (boolean). All
    #             properties are optional, unless used as a lookup key; however, either a `name` or
    #             `phone_number` property must be provided for new contacts.
    #         * Required
    #     
    #     - lookup_key
    #         * The field used to search for a matching contact, or 'none' to always create a new
    #             contact. To search by a custom variable, precede the variable name with 'vars.'.
    #         * Allowed values: phone_number, id, vars.variable_name, none
    #         * Default: phone_number
    #     
    #     - add_group_ids (array)
    #         * ID of one or more groups to add these contacts as members (max 5)
    #     
    #     - remove_group_ids (array)
    #         * ID of one or more groups to remove these contacts as members (max 5)
    #     
    #     - default_route_id
    #         * ID of the route to use by default to send messages to these contacts
    #   
    # Returns:
    #     (associative array)
    #       - contacts (array)
    #           * List of objects representing each contact, with the same length and order as
    #               provided in the `contacts` parameter in the API request. Each object has a string
    #               `id` property.
    #
    def import_contacts(options)
        data = @api.do_request("POST", get_base_api_path() + "/import_contacts", options)
        return data
    end

    #
    # Queries contacts within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter contacts by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - phone_number
    #         * Filter contacts by phone number
    #         * Allowed modifiers: phone_number[ne], phone_number[prefix],
    #             phone_number[not_prefix], phone_number[gte], phone_number[gt], phone_number[lt],
    #             phone_number[lte]
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter contacts by time created
    #         * Allowed modifiers: time_created[ne], time_created[min], time_created[max]
    #     
    #     - last_message_time (UNIX timestamp)
    #         * Filter contacts by last time a message was sent or received
    #         * Allowed modifiers: last_message_time[exists], last_message_time[ne],
    #             last_message_time[min], last_message_time[max]
    #     
    #     - last_incoming_message_time (UNIX timestamp)
    #         * Filter contacts by last time a message was received
    #         * Allowed modifiers: last_incoming_message_time[exists],
    #             last_incoming_message_time[ne], last_incoming_message_time[min],
    #             last_incoming_message_time[max]
    #     
    #     - last_outgoing_message_time (UNIX timestamp)
    #         * Filter contacts by last time a message was sent
    #         * Allowed modifiers: last_outgoing_message_time[exists],
    #             last_outgoing_message_time[ne], last_outgoing_message_time[min],
    #             last_outgoing_message_time[max]
    #     
    #     - incoming_message_count (int)
    #         * Filter contacts by number of messages received from the contact
    #         * Allowed modifiers: incoming_message_count[ne], incoming_message_count[min],
    #             incoming_message_count[max]
    #     
    #     - outgoing_message_count (int)
    #         * Filter contacts by number of messages sent to the contact
    #         * Allowed modifiers: outgoing_message_count[ne], outgoing_message_count[min],
    #             outgoing_message_count[max]
    #     
    #     - send_blocked (bool)
    #         * Filter contacts by blocked status
    #     
    #     - vars (Hash)
    #         * Filter contacts by value of a custom variable (e.g. vars[email], vars[foo], etc.)
    #         * Allowed modifiers: vars[foo][exists], vars[foo][ne], vars[foo][prefix],
    #             vars[foo][not_prefix], vars[foo][gte], vars[foo][gt], vars[foo][lt], vars[foo][lte],
    #             vars[foo][min], vars[foo][max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name, phone_number, last_message_time
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
    #     Telerivet::APICursor (of Telerivet::Contact)
    #
    def query_contacts(options = nil)
        require_relative 'contact'
        @api.cursor(Contact, get_base_api_path() + "/contacts", options)
    end

    #
    # Retrieves the contact with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the contact
    #       * Required
    #   
    # Returns:
    #     Telerivet::Contact
    #
    def get_contact_by_id(id)
        require_relative 'contact'
        Contact.new(@api, @api.do_request("GET", get_base_api_path() + "/contacts/#{id}"))
    end

    #
    # Initializes the Telerivet contact with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the contact
    #       * Required
    #   
    # Returns:
    #     Telerivet::Contact
    #
    def init_contact_by_id(id)
        require_relative 'contact'
        return Contact.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries phones within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter phones by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - phone_number
    #         * Filter phones by phone number
    #         * Allowed modifiers: phone_number[ne], phone_number[prefix],
    #             phone_number[not_prefix], phone_number[gte], phone_number[gt], phone_number[lt],
    #             phone_number[lte]
    #     
    #     - last_active_time (UNIX timestamp)
    #         * Filter phones by last active time
    #         * Allowed modifiers: last_active_time[exists], last_active_time[ne],
    #             last_active_time[min], last_active_time[max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name, phone_number
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
    #     Telerivet::APICursor (of Telerivet::Phone)
    #
    def query_phones(options = nil)
        require_relative 'phone'
        @api.cursor(Phone, get_base_api_path() + "/phones", options)
    end

    #
    # Retrieves the phone with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the phone - see <https://telerivet.com/dashboard/api>
    #       * Required
    #   
    # Returns:
    #     Telerivet::Phone
    #
    def get_phone_by_id(id)
        require_relative 'phone'
        Phone.new(@api, @api.do_request("GET", get_base_api_path() + "/phones/#{id}"))
    end

    #
    # Initializes the phone with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the phone - see <https://telerivet.com/dashboard/api>
    #       * Required
    #   
    # Returns:
    #     Telerivet::Phone
    #
    def init_phone_by_id(id)
        require_relative 'phone'
        return Phone.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries messages within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - direction
    #         * Filter messages by direction
    #         * Allowed values: incoming, outgoing
    #     
    #     - message_type
    #         * Filter messages by message_type
    #         * Allowed values: sms, mms, ussd, call
    #     
    #     - source
    #         * Filter messages by source
    #         * Allowed values: phone, provider, web, api, service, webhook, scheduled
    #     
    #     - starred (bool)
    #         * Filter messages by starred/unstarred
    #     
    #     - status
    #         * Filter messages by status
    #         * Allowed values: ignored, processing, received, sent, queued, failed,
    #             failed_queued, cancelled, delivered, not_delivered
    #     
    #     - time_created[min] (UNIX timestamp)
    #         * Filter messages created on or after a particular time
    #     
    #     - time_created[max] (UNIX timestamp)
    #         * Filter messages created before a particular time
    #     
    #     - external_id
    #         * Filter messages by ID from an external provider
    #     
    #     - contact_id
    #         * ID of the contact who sent/received the message
    #     
    #     - phone_id
    #         * ID of the phone (basic route) that sent/received the message
    #     
    #     - broadcast_id
    #         * ID of the broadcast containing the message
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
    #     Telerivet::APICursor (of Telerivet::Message)
    #
    def query_messages(options = nil)
        require_relative 'message'
        @api.cursor(Message, get_base_api_path() + "/messages", options)
    end

    #
    # Retrieves the message with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the message
    #       * Required
    #   
    # Returns:
    #     Telerivet::Message
    #
    def get_message_by_id(id)
        require_relative 'message'
        Message.new(@api, @api.do_request("GET", get_base_api_path() + "/messages/#{id}"))
    end

    #
    # Initializes the Telerivet message with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the message
    #       * Required
    #   
    # Returns:
    #     Telerivet::Message
    #
    def init_message_by_id(id)
        require_relative 'message'
        return Message.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries broadcasts within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - time_created[min] (UNIX timestamp)
    #         * Filter broadcasts created on or after a particular time
    #     
    #     - time_created[max] (UNIX timestamp)
    #         * Filter broadcasts created before a particular time
    #     
    #     - last_message_time[min] (UNIX timestamp)
    #         * Filter broadcasts with most recent message on or after a particular time
    #     
    #     - last_message_time[max] (UNIX timestamp)
    #         * Filter broadcasts with most recent message before a particular time
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, last_message_time
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
    #     Telerivet::APICursor (of Telerivet::Broadcast)
    #
    def query_broadcasts(options = nil)
        require_relative 'broadcast'
        @api.cursor(Broadcast, get_base_api_path() + "/broadcasts", options)
    end

    #
    # Retrieves the broadcast with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the broadcast
    #       * Required
    #   
    # Returns:
    #     Telerivet::Broadcast
    #
    def get_broadcast_by_id(id)
        require_relative 'broadcast'
        Broadcast.new(@api, @api.do_request("GET", get_base_api_path() + "/broadcasts/#{id}"))
    end

    #
    # Initializes the Telerivet broadcast with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the broadcast
    #       * Required
    #   
    # Returns:
    #     Telerivet::Broadcast
    #
    def init_broadcast_by_id(id)
        require_relative 'broadcast'
        return Broadcast.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries groups within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter groups by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - dynamic (bool)
    #         * Filter groups by dynamic/non-dynamic
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
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
    #     Telerivet::APICursor (of Telerivet::Group)
    #
    def query_groups(options = nil)
        require_relative 'group'
        @api.cursor(Group, get_base_api_path() + "/groups", options)
    end

    #
    # Retrieves or creates a group by name.
    # 
    # Arguments:
    #   - name
    #       * Name of the group
    #       * Required
    #   
    # Returns:
    #     Telerivet::Group
    #
    def get_or_create_group(name)
        require_relative 'group'
        Group.new(@api, @api.do_request("POST", get_base_api_path() + "/groups", {'name' => name}))
    end

    #
    # Retrieves the group with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the group
    #       * Required
    #   
    # Returns:
    #     Telerivet::Group
    #
    def get_group_by_id(id)
        require_relative 'group'
        Group.new(@api, @api.do_request("GET", get_base_api_path() + "/groups/#{id}"))
    end

    #
    # Initializes the group with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the group
    #       * Required
    #   
    # Returns:
    #     Telerivet::Group
    #
    def init_group_by_id(id)
        require_relative 'group'
        return Group.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries labels within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter labels by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
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
    #     Telerivet::APICursor (of Telerivet::Label)
    #
    def query_labels(options = nil)
        require_relative 'label'
        @api.cursor(Label, get_base_api_path() + "/labels", options)
    end

    #
    # Gets or creates a label by name.
    # 
    # Arguments:
    #   - name
    #       * Name of the label
    #       * Required
    #   
    # Returns:
    #     Telerivet::Label
    #
    def get_or_create_label(name)
        require_relative 'label'
        Label.new(@api, @api.do_request("POST", get_base_api_path() + "/labels", {'name' => name}))
    end

    #
    # Retrieves the label with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the label
    #       * Required
    #   
    # Returns:
    #     Telerivet::Label
    #
    def get_label_by_id(id)
        require_relative 'label'
        Label.new(@api, @api.do_request("GET", get_base_api_path() + "/labels/#{id}"))
    end

    #
    # Initializes the label with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the label
    #       * Required
    #   
    # Returns:
    #     Telerivet::Label
    #
    def init_label_by_id(id)
        require_relative 'label'
        return Label.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries data tables within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter data tables by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
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
    #     Telerivet::APICursor (of Telerivet::DataTable)
    #
    def query_data_tables(options = nil)
        require_relative 'datatable'
        @api.cursor(DataTable, get_base_api_path() + "/tables", options)
    end

    #
    # Gets or creates a data table by name.
    # 
    # Arguments:
    #   - name
    #       * Name of the data table
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataTable
    #
    def get_or_create_data_table(name)
        require_relative 'datatable'
        DataTable.new(@api, @api.do_request("POST", get_base_api_path() + "/tables", {'name' => name}))
    end

    #
    # Retrieves the data table with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the data table
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataTable
    #
    def get_data_table_by_id(id)
        require_relative 'datatable'
        DataTable.new(@api, @api.do_request("GET", get_base_api_path() + "/tables/#{id}"))
    end

    #
    # Initializes the data table with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the data table
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataTable
    #
    def init_data_table_by_id(id)
        require_relative 'datatable'
        return DataTable.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries scheduled messages within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - message_type
    #         * Filter scheduled messages by message_type
    #         * Allowed values: sms, mms, ussd, call
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter scheduled messages by time_created
    #         * Allowed modifiers: time_created[ne], time_created[min], time_created[max]
    #     
    #     - next_time (UNIX timestamp)
    #         * Filter scheduled messages by next_time
    #         * Allowed modifiers: next_time[exists], next_time[ne], next_time[min],
    #             next_time[max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
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
    #     Telerivet::APICursor (of Telerivet::ScheduledMessage)
    #
    def query_scheduled_messages(options = nil)
        require_relative 'scheduledmessage'
        @api.cursor(ScheduledMessage, get_base_api_path() + "/scheduled", options)
    end

    #
    # Retrieves the scheduled message with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the scheduled message
    #       * Required
    #   
    # Returns:
    #     Telerivet::ScheduledMessage
    #
    def get_scheduled_message_by_id(id)
        require_relative 'scheduledmessage'
        ScheduledMessage.new(@api, @api.do_request("GET", get_base_api_path() + "/scheduled/#{id}"))
    end

    #
    # Initializes the scheduled message with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the scheduled message
    #       * Required
    #   
    # Returns:
    #     Telerivet::ScheduledMessage
    #
    def init_scheduled_message_by_id(id)
        require_relative 'scheduledmessage'
        return ScheduledMessage.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries services within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter services by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - active (bool)
    #         * Filter services by active/inactive state
    #     
    #     - context
    #         * Filter services that can be invoked in a particular context
    #         * Allowed values: message, call, contact, project
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, priority, name
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
    #     Telerivet::APICursor (of Telerivet::Service)
    #
    def query_services(options = nil)
        require_relative 'service'
        @api.cursor(Service, get_base_api_path() + "/services", options)
    end

    #
    # Retrieves the service with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the service
    #       * Required
    #   
    # Returns:
    #     Telerivet::Service
    #
    def get_service_by_id(id)
        require_relative 'service'
        Service.new(@api, @api.do_request("GET", get_base_api_path() + "/services/#{id}"))
    end

    #
    # Initializes the service with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the service
    #       * Required
    #   
    # Returns:
    #     Telerivet::Service
    #
    def init_service_by_id(id)
        require_relative 'service'
        return Service.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries custom routes that can be used to send messages (not including Phones).
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter routes by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
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
    #     Telerivet::APICursor (of Telerivet::Route)
    #
    def query_routes(options = nil)
        require_relative 'route'
        @api.cursor(Route, get_base_api_path() + "/routes", options)
    end

    #
    # Gets a custom route by ID
    # 
    # Arguments:
    #   - id
    #       * ID of the route
    #       * Required
    #   
    # Returns:
    #     Telerivet::Route
    #
    def get_route_by_id(id)
        require_relative 'route'
        Route.new(@api, @api.do_request("GET", get_base_api_path() + "/routes/#{id}"))
    end

    #
    # Initializes a custom route by ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the route
    #       * Required
    #   
    # Returns:
    #     Telerivet::Route
    #
    def init_route_by_id(id)
        require_relative 'route'
        return Route.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Returns an array of user accounts that have access to this project. Each item in the array
    # is an object containing `id`, `email`, and `name` properties. (The id corresponds to the
    # `user_id` property of the Message object.)
    # 
    # Returns:
    #     array
    #
    def get_users()
        return @api.do_request("GET", get_base_api_path() + "/users")
    end

    #
    # Saves any fields or custom variables that have changed for the project.
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

    def timezone_id
        get('timezone_id')
    end

    def url_slug
        get('url_slug')
    end

    def organization_id
        get('organization_id')
    end

    def get_base_api_path()
        "/projects/#{get('id')}"
    end
 
end

end
