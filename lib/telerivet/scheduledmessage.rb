
module Telerivet

#
# Represents a scheduled message within Telerivet.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the scheduled message
#       * Read-only
#   
#   - content
#       * Text content of the scheduled message
#       * Read-only
#   
#   - rrule
#       * Recurrence rule for recurring scheduled messages, e.g. 'FREQ=MONTHLY' or
#           'FREQ=WEEKLY;INTERVAL=2'; see <https://tools.ietf.org/html/rfc2445#section-4.3.10>
#       * Read-only
#   
#   - timezone_id
#       * Timezone ID used to compute times for recurring messages; see
#           <http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
#       * Read-only
#   
#   - group_id
#       * ID of the group to send the message to (null if scheduled to an individual contact)
#       * Read-only
#   
#   - contact_id
#       * ID of the contact to send the message to (null if scheduled to a group)
#       * Read-only
#   
#   - to_number
#       * Phone number to send the message to (null if scheduled to a group)
#       * Read-only
#   
#   - route_id
#       * ID of the phone or route the message will be sent from
#       * Read-only
#   
#   - service_id (string, max 34 characters)
#       * The service associated with this message (for voice calls, the service defines the
#           call flow)
#       * Read-only
#   
#   - audio_url
#       * For voice calls, the URL of an MP3 file to play when the contact answers the call
#       * Read-only
#   
#   - tts_lang
#       * For voice calls, the language of the text-to-speech voice
#       * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
#           de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
#       * Read-only
#   
#   - tts_voice
#       * For voice calls, the text-to-speech voice
#       * Allowed values: female, male
#       * Read-only
#   
#   - message_type
#       * Type of scheduled message
#       * Allowed values: sms, ussd, call
#       * Read-only
#   
#   - time_created (UNIX timestamp)
#       * Time the scheduled message was created in Telerivet
#       * Read-only
#   
#   - start_time (UNIX timestamp)
#       * The time that the message will be sent (or first sent for recurring messages)
#       * Read-only
#   
#   - end_time (UNIX timestamp)
#       * Time after which a recurring message will stop (not applicable to non-recurring
#           scheduled messages)
#       * Read-only
#   
#   - prev_time (UNIX timestamp)
#       * The most recent time that Telerivet has sent this scheduled message (null if it has
#           never been sent)
#       * Read-only
#   
#   - next_time (UNIX timestamp)
#       * The next upcoming time that Telerivet will sent this scheduled message (null if it
#           will not be sent again)
#       * Read-only
#   
#   - occurrences (int)
#       * Number of times this scheduled message has already been sent
#       * Read-only
#   
#   - is_template (bool)
#       * Set to true if Telerivet will render variables like [[contact.name]] in the message
#           content, false otherwise
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this scheduled message (copied to Message when sent)
#       * Updatable via API
#   
#   - label_ids (array)
#       * IDs of labels to add to the Message
#       * Read-only
#   
#   - project_id
#       * ID of the project this scheduled message belongs to
#       * Read-only
#
class ScheduledMessage < Entity
    #
    # Saves any fields or custom variables that have changed for this scheduled message.
    #
    def save()
        super
    end

    #
    # Cancels this scheduled message.
    #
    def delete()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def content
        get('content')
    end

    def rrule
        get('rrule')
    end

    def timezone_id
        get('timezone_id')
    end

    def group_id
        get('group_id')
    end

    def contact_id
        get('contact_id')
    end

    def to_number
        get('to_number')
    end

    def route_id
        get('route_id')
    end

    def service_id
        get('service_id')
    end

    def audio_url
        get('audio_url')
    end

    def tts_lang
        get('tts_lang')
    end

    def tts_voice
        get('tts_voice')
    end

    def message_type
        get('message_type')
    end

    def time_created
        get('time_created')
    end

    def start_time
        get('start_time')
    end

    def end_time
        get('end_time')
    end

    def prev_time
        get('prev_time')
    end

    def next_time
        get('next_time')
    end

    def occurrences
        get('occurrences')
    end

    def is_template
        get('is_template')
    end

    def label_ids
        get('label_ids')
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/scheduled/#{get('id')}"
    end
 
end

end
