class Api::Current::Schema
  class << self
    def processed_since
      Api::Current::Schema::Models.timestamp.merge(
        name: 'processed_since',
        description: 'The timestamp since which records have been processed by the server.
                    Use the server returned value in the next request to continue fetching records.'
      )
    end

    def error
      { type: :object,
        properties: {
          id: { type: :string,
                format: :uuid,
                description: 'Id of the record with errors' },
          schema: { type: :array,
                    items: { type: :string },
                    description: 'List of json schema error strings describing validation errors' },
          field_with_error: { type: :array,
                              items: { type: :string } } } }
    end

    def sync_from_user_request(request_key, schema_type = request_key)
      { type: :object,
        properties: {
          request_key => { '$ref' => "#/definitions/#{schema_type}" } },
        required: [request_key] }
    end

    def sync_from_user_errors
      { type: :object,
        properties: {
          errors: { '$ref' => '#/definitions/errors' } } }
    end

    def sync_to_user_request
      [processed_since.merge(in: :query),
       { in: :query, name: :limit, type: :integer,
         description: 'Number of record to retrieve (a.k.a batch-size)' }]
    end

    def sync_to_user_response(response_key, schema_type = response_key)
      { type: :object,
        properties: {
          response_key => { '$ref' => "#/definitions/#{schema_type}" },
          :processed_since => { '$ref' => '#/definitions/processed_since' } },
        required: [response_key, :processed_since] }
    end

    def patient_sync_from_user_request
      sync_from_user_request(:patients, 'nested_patients')
    end

    def blood_pressure_sync_from_user_request
      sync_from_user_request(:blood_pressures)
    end

    def prescription_drug_sync_from_user_request
      sync_from_user_request(:prescription_drugs)
    end

    def communication_sync_from_user_request
      sync_from_user_request(:communication)
    end

    def appointment_sync_from_user_request
      sync_from_user_request(:appointments)
    end

    def medical_history_sync_from_user_request
      sync_from_user_request(:medical_histories)
    end

    def patient_sync_to_user_response
      sync_to_user_response(:patients, 'nested_patients')
    end

    def blood_pressure_sync_to_user_response
      sync_to_user_response(:blood_pressures)
    end

    def prescription_drug_sync_to_user_response
      sync_to_user_response(:prescription_drugs)
    end

    def protocol_sync_to_user_response
      sync_to_user_response(:protocols)
    end

    def facility_sync_to_user_response
      sync_to_user_response(:facilities)
    end

    def communication_sync_to_user_response
      sync_to_user_response(:communications)
    end


    def appointment_sync_to_user_response
      sync_to_user_response(:appointments)
    end

    def medical_history_sync_to_user_response
      sync_to_user_response(:medical_histories)
    end

    def user_login_request
      { type: :object,
        properties: {
          user: { '$ref' => '#/definitions/login_user' } },
        required: [:user] }
    end

    def user_registration_response
      { type: :object,
        properties: {
          access_token: { '$ref' => '#/definitions/non_empty_string' },
          user: { '$ref' => '#/definitions/user' } },
        required: %i[user access_token] }
    end

    def user_login_success_response
      user_registration_response
    end

    def user_registration_request
      { type: :object,
        properties: {
          user: { '$ref' => '#/definitions/user' } },
        required: %i[user] }
    end

    def user_reset_password_request
      { type: :object,
        properties: {
          password_digest: { '$ref' => '#/definitions/bcrypt_password' } },
        required: %i[passowrd_digest] }
    end

    def definitions
      { error: error,
        errors: Api::Current::Schema::Models.array_of('error'),
        processed_since: processed_since }
    end

    def all_definitions
      definitions.merge(Api::Current::Schema::Models.definitions)
    end

    def swagger_info(version)
      {
        description: I18n.t('api.documentation.description'),
        version: version.to_s,
        title: I18n.t('api.documentation.title'),
        'x-logo' => {
          url: ActionController::Base.helpers.image_path(I18n.t('api.documentation.logo.image')),
          backgroundColor: I18n.t('api.documentation.logo.background_color')
        },
        contact: {
          email: I18n.t('api.documentation.contact.email')
        },
        license: {
          name: I18n.t('api.documentation.license.name'),
          url: I18n.t('api.documentation.license.url')
        }
      }
    end

    def security_definitions
      { basic: {
        type: :basic
      } }
    end

    def swagger_docs
      {
        'current/swagger.json' => {
          swagger: '2.0',
          basePath: '/api/v2',
          produces: ['application/json'],
          consumes: ['application/json'],
          schemes: ['https'],
          info: swagger_info(:v2),
          paths: {},
          definitions: all_definitions,
          securityDefinitions: security_definitions
        },
        'v1/swagger.json' => {
          swagger: '2.0',
          basePath: '/api/v1',
          produces: ['application/json'],
          consumes: ['application/json'],
          schemes: ['https'],
          info: swagger_info(:v1),
          paths: {},
          definitions: all_definitions,
          securityDefinitions: security_definitions
        }
      }
    end
  end
end
